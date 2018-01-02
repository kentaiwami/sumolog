//
//  SettingViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/02.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import KeychainAccess
import SwiftyJSON

class SettingViewController: FormViewController {

    private var iscreate = false
    private var user_data = UserData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = UIColor.blue
        

        // Do any additional setup after loading the view.
        if iscreate {
            user_data.Setprice(price: 0)
            user_data.Setpayday(payday: 0)
            user_data.Setaddress(address: "")
            user_data.Settarget_number(target_number: 0)
        }else {
            CallGetSettingAPI()
        }
        
        CreateForm()
    }
    
    func CallGetSettingAPI() {
        let keychain = Keychain()
        let id = try! keychain.getString("id")
        
        let urlString = API.base.rawValue + API.user.rawValue + id!
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("User Setting results: ", json.count)
            print(json)
            self.user_data.SetAll(json: json)
        }
    }
    
    func CreateForm() {
        let RuleRequired_M = "必須項目です"
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        form +++ Section("ユーザ情報")
            <<< PickerInputRow<Int>(""){
                $0.title = "給与日"
                $0.value = user_data.Getpayday()
                $0.options = GenerateDate()
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "payday"
            }
            .onRowValidationChanged {cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
            
            <<< IntRow(){
                $0.title = "値段"
                $0.value = user_data.Getprice()
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "price"
            }
            .onRowValidationChanged {cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
        
            <<< IntRow(){
                $0.title = "目標"
                $0.value = user_data.Gettarget_number()
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "target_number"
            }
            .onRowValidationChanged {cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
    }
    
    func SetisCreate(iscreate: Bool) {
        self.iscreate = iscreate
    }
    
    func GenerateDate() -> Array<Int> {
        var date_array:[Int] = []
        for i in 1...31 {
            date_array.append(i)
        }
        
        return date_array
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
