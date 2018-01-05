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

class SmokeDataViewController: FormViewController {

    var iscreated_form = false
    let indicator = Indicator()
    var id = ""
    var uuid = ""
    var results:[JSON] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Edit"
        
        CallGet24HourSmokeAPI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keychain = Keychain()
        id = (try! keychain.getString("id"))!
        uuid = (try! keychain.getString("uuid"))!
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
//            if !self.iscreated_form {
                self.CreateForms()
//            }
//            self.UpdateCells()
        }
    }
    
    func CreateForms() {
        form.removeAll()
        
        iscreated_form = true
        
        let section = Section()
        
        for smoke in results {
//            print(smoke)
//            let vc = SmokeDataFormViewController()
//            vc.SetTitle(title: "Edit")
        }
//
//
//            vc.SetIsAdd(flag: false)
//            vc.SetProductID(id: p["id"].intValue)
//
//            let row = ButtonRow() {
//                $0.title = p["title"].stringValue
//                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return vc},
//                                            onDismiss: { vc in
//                                                vc.navigationController?.popViewController(animated: true)}
//                )
//            }
//            section.append(row)
//        }
        
        form.append(section)

    }
    
    func UpdateCells() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
