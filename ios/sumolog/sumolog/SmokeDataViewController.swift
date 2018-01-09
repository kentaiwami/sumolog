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

class SmokeDataViewController: FormViewController, UITabBarControllerDelegate {

    var preViewName = StoryBoardID.edit.rawValue
    let indicator = Indicator()
    let refresh_controll = UIRefreshControl()
    
    var id = ""
    var uuid = ""
    var results:[JSON] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Edit"
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.ShowSmokeCreateViewController(sender:)))
        self.tabBarController?.navigationItem.setRightBarButton(add, animated: true)
        
        CallGet24HourSmokeAPI(show_indicator: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keychain = Keychain()
        id = (try! keychain.getString("id"))!
        uuid = (try! keychain.getString("uuid"))!
        
        self.tabBarController?.delegate = self
        
        self.tableView.refreshControl = self.refresh_controll
        self.refresh_controll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    
    func CallGet24HourSmokeAPI(show_indicator: Bool) {
        if show_indicator {
            indicator.showIndicator(view: self.view)
        }
        
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + API.hour24.rawValue + API.user.rawValue + id + "/" + uuid
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in

            // pullされてAPIを叩かれた場合
            if !show_indicator {
                self.refresh_controll.endRefreshing()
            }
            
            self.indicator.stopIndicator()
            
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("Smoke 24hour results: ", json.count)
            print(json["results"])
            
            self.results = json["results"].arrayValue
            self.CreateForms()
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        refresh_controll.beginRefreshing()
        CallGet24HourSmokeAPI(show_indicator: false)
    }
    
    func CreateForms() {
        UIView.setAnimationsEnabled(false)
        
        form.removeAll()
        
        let section = Section("24hour Smoked")
        
        for smoke in results {
            let title = "Start： " + smoke["started_at"].stringValue + "\n" + "End：   " + smoke["ended_at"].stringValue
            let vc = SmokeDataEditViewController()
            vc.SetSmokeID(id: smoke["id"].intValue)
            vc.SetStartedAt(started_at: smoke["started_at"].stringValue)
            vc.SetEndedAt(ended_at: smoke["ended_at"].stringValue)
            
            let row = ButtonRow() {
                $0.title = title
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return vc}, onDismiss: {vc in vc.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            section.append(row)
        }
        
        form.append(section)
        
        UIView.setAnimationsEnabled(true)
    }
    
    func ShowSmokeCreateViewController(sender: UIButton) {
        let vc = SmokeDataCreateViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryBoardID.edit.rawValue && preViewName == StoryBoardID.edit.rawValue {
            tableView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
