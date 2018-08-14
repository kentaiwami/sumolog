//
//  EditViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/05.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON
import Alamofire
import KeychainAccess
import StatusProvider
import PromiseKit

class OldSmokeDataViewController: FormViewController, UITabBarControllerDelegate, StatusController {

    var preViewName = StoryBoardID.edit.rawValue
    let indicator = Indicator()
    let refresh_controll = UIRefreshControl()
    
    var id = ""
    var uuid = ""
    var results:[JSON] = []
    let keychain = Keychain()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Edit"
        
        SetUpButton()
        
        CallGet24HourSmokeAPI(show_indicator: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        id = (try! keychain.getString("id"))!
        uuid = (try! keychain.getString("uuid"))!
        
        let is_smoking = try! keychain.getString("is_smoking")
        let smoke_id = try! keychain.getString("smoke_id")
        
        if is_smoking == nil {
            try! keychain.set(String(false), key: "is_smoking")
        }
        
        if smoke_id == nil {
            try! keychain.set("", key: "smoke_id")
        }
        
        self.tabBarController?.delegate = self
        
        self.tableView.refreshControl = self.refresh_controll
        self.refresh_controll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    
    func SetUpButton() {
        if NSString(string: (try! keychain.getString("is_smoking"))!).boolValue {
            let check = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(TapSmokeEndButton))
            self.tabBarController?.navigationItem.setRightBarButton(check, animated: true)
        }else {
            let add = UIBarButtonItem(image: UIImage(named: "icon_add"), style: .plain, target: self, action: #selector(TapSmokeStartButton))
            self.tabBarController?.navigationItem.setRightBarButton(add, animated: true)
        }
    }
    
    func CallGet24HourSmokeAPI(show_indicator: Bool) {
        if show_indicator {
            indicator.start()
        }
        
        let urlString = APIOld.base.rawValue + APIOld.v1.rawValue + APIOld.smoke.rawValue + APIOld.hour24.rawValue + APIOld.user.rawValue + id
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            // pullされてAPIを叩かれた場合
            if !show_indicator {
                self.refresh_controll.endRefreshing()
            }
            
            self.indicator.stop()
            
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("Smoke 24hour results: ", json.count)
            print(json["results"])
            
            self.results = json["results"].arrayValue
            self.DrawView()
        }
    }
    
    func CallCreateSmokeAPI(endpoint: String, method: HTTPMethod) -> Promise<Int> {
        let urlString = APIOld.base.rawValue + APIOld.v1.rawValue + endpoint
        let param = [
            "uuid": uuid,
            "minus_sec": 0,
            "is_sensor": false
            ] as [String : Any]
        
        let promise = Promise<Int> { seal in
            Alamofire.request(urlString, method: method, parameters: param, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                guard let object = response.result.value else{return}
                let json = JSON(object)
                print("Smoke create update results: ", json.count)
                print(json)
                seal.fulfill(json["smoke_id"].intValue)
            }
        }
        
        return promise
    }
    
    func refresh(sender: UIRefreshControl) {
        refresh_controll.beginRefreshing()
        CallGet24HourSmokeAPI(show_indicator: false)
    }
    
    func DrawView() {
        UIView.setAnimationsEnabled(false)
        ResetViews()
        
        if results.count == 0 {
            let status = Status(title: "No Data", description: "喫煙記録がないため、データを表示できません", actionTitle: "Reload", image: nil) {
                self.hideStatus()
                self.CallGet24HourSmokeAPI(show_indicator: true)
            }
            show(status: status)
        }else {
            CreateForm()
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func ResetViews() {
        self.hideStatus()
        form.removeAll()
    }
    
    func CreateForm() {
        let section = Section("24hour Smoked")
        
        for smoke in results {
            let start = Date.stringFromString(string: smoke["started_at"].stringValue, formatIn: "yyyy-MM-dd HH:mm:ss", formatOut: "yyyy-MM-dd HH:mm")
            
            var end = ""
            if smoke["ended_at"].stringValue == "" {
                end = ""
            }else {
                end = Date.stringFromString(string: smoke["ended_at"].stringValue, formatIn: "yyyy-MM-dd HH:mm:ss", formatOut: "yyyy-MM-dd HH:mm")
            }
            
            let title = "\(start)\n\(end)"
            
            let vc = OldSmokeDataEditViewController()
            vc.SetSmokeID(id: smoke["id"].intValue)
            vc.SetStartedAt(started_at: smoke["started_at"].stringValue)
            vc.SetEndedAt(ended_at: smoke["ended_at"].stringValue)
            
            let row = ButtonRow() {
                $0.title = title
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return vc}, onDismiss: {vc in vc.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
                $0.cell.textLabel?.text = title
            }
            
            section.append(row)
        }
        
        form.append(section)
    }
    
    func TapSmokeStartButton() {
        let ended_at_null = results.filter({$0["ended_at"].stringValue.isEmpty})
        
        // ended_atがnull(文字数 0)のレコードがある場合は、センサーで計測中の可能性があるので警告アラートを表示
        if ended_at_null.count == 0 {
            self.CreateSmoke()
        }else {
            let alert = GetOKCancelAlert(title: "警告", message: "センサーが計測中の可能性があります。ここで新規に記録をした場合、2重で記録される場合があります。\nそれでも記録しますか？", ok_action: {
                self.CreateSmoke()
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func CreateSmoke() {
        indicator.start()
        
        CallCreateSmokeAPI(endpoint: APIOld.smoke.rawValue, method: .post).done { smoke_id in
            try! self.keychain.set(String(smoke_id), key: "smoke_id")
            try! self.keychain.set(String(true), key: "is_smoking")
            self.SetUpButton()
            
            self.indicator.stop()
            self.CallGet24HourSmokeAPI(show_indicator: true)
            
            self.present(GetStandardAlert(title: "Started", message: "喫煙開始を記録しました。\n右上のチェックボタンをタップして喫煙終了を記録してください。", b_title: "OK"), animated: true, completion: nil)
        }
    }
    
    func TapSmokeEndButton() {
        let smoke_id = (try! keychain.getString("smoke_id"))!
        
        indicator.start()
        
        
        CallCreateSmokeAPI(endpoint: APIOld.smoke.rawValue+smoke_id, method: .put).done { _ in
            try! self.keychain.set("", key: "smoke_id")
            try! self.keychain.set(String(false), key: "is_smoking")
            self.SetUpButton()
            
            self.indicator.stop()
            self.CallGet24HourSmokeAPI(show_indicator: true)
            self.present(GetStandardAlert(title: "Ended", message: "喫煙終了を記録しました。", b_title: "OK"), animated: true, completion: nil)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryBoardID.edit.rawValue && preViewName == StoryBoardID.edit.rawValue {
            tableView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
