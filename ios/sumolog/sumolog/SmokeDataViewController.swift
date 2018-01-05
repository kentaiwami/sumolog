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

    var preViewName = StoryBoardID.smokedataview.rawValue
    let indicator = Indicator()
    var id = ""
    var uuid = ""
    var results:[JSON] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Smoke 24hour"
        
        CallGet24HourSmokeAPI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keychain = Keychain()
        id = (try! keychain.getString("id"))!
        uuid = (try! keychain.getString("uuid"))!
        
        self.tabBarController?.delegate = self
    }
    
    func CallGet24HourSmokeAPI() {
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + API.hour24.rawValue + API.user.rawValue + id + "/" + uuid
        indicator.showIndicator(view: self.view)
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            self.indicator.stopIndicator()
            
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("Smoke 24hour results: ", json.count)
            print(json["results"])
            
            self.results = json["results"].arrayValue
            self.CreateForms()
        }
    }
    
    func CreateForms() {
        UIView.setAnimationsEnabled(false)
        
        form.removeAll()
        
        let section = Section()
        
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryBoardID.smokedataview.rawValue && preViewName == StoryBoardID.smokedataview.rawValue {
            tableView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
