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

class EditViewController: UIViewController {

    var iscreated_form = false
    let indicator = Indicator()
    var id = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Edit"
        
        CallGet24HourSmokeAPI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keychain = Keychain()
        id = (try! keychain.getString("id"))!
    }
    
    func CallGet24HourSmokeAPI() {
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + API.detail.rawValue + API.user.rawValue + id
        indicator.showIndicator(view: self.view)
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            self.indicator.stopIndicator()
            
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("Smoke 24hour results: ", json.count)
            print(json)
            
            if !self.iscreated_form {
                self.CreateForms()
            }
            self.UpdateCells()
        }
    }
    
    func CreateForms() {
        iscreated_form = true
    }
    
    func UpdateCells() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
