//
//  SignUpViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/02/01.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import KeychainAccess
import SwiftyJSON
import PromiseKit

class SignUpViewController: FormViewController {

    let keychain = Keychain()
    let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sign Up"
        tableView.isScrollEnabled = false
        CreateForm()
    }
    
    func CreateForm() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        var rules = RuleSet<Int>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        rules.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))
        
        form +++ Section(header: "ユーザ情報", footer: "")
            <<< PickerInputRow<Int>(""){
                $0.title = "給与日"
                $0.value = 25
                $0.options = GenerateDate()
                $0.tag = "payday"
            }
            
            
            <<< IntRow(){
                $0.title = "1本の値段"
                $0.value = 0
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "price"
            }
            .onRowValidationChanged {cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = err
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            
            <<< IntRow(){
                $0.title = "1日の目標本数"
                $0.value = 0
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "target_number"
            }
            .onRowValidationChanged {cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = err
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            
            <<< SwitchRow(){
                $0.title = "センサーを設置済み"
                $0.value = false
                $0.tag = "sensor_set"
            }
            <<< TextRow(){
                $0.title = "センサーのIPアドレス"
                $0.value = ""
                $0.add(rule: RuleRegExp(regExpr: "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}", allowsEmpty: false, msg: "形式を確認してください。ex.) 192.168.0.0"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "address"
                $0.hidden = Condition.function(["sensor_set"], { form in
                    return !((form.rowBy(tag: "sensor_set") as? SwitchRow)?.value ?? false)
                })
            }
            .onRowValidationChanged {cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = err
                            $0.cell.height = { 30 }
                            $0.hidden = Condition.function(["sensor_set"], { form in
                                return !((form.rowBy(tag: "sensor_set") as? SwitchRow)?.value ?? false)
                            })
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
        
        form +++ Section()
            <<< ButtonRow(){
                $0.title = "Sign Up"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                self.CallAPI()
                print(self.form.values())
            }
    }
    
    func CallAPI() {
        if IsCheckFormValue(form: form) {
            indicator.showIndicator(view: tableView)
            
            CallSaveUUIDAPI().then { uuid in
                return self.CallCreateUserAPI(uuid: uuid)
                }.then { json -> Void in
                    self.indicator.stopIndicator()
                    
                    try! self.keychain.set(json["uuid"].stringValue, key: "uuid")
                    try! self.keychain.set(String(json["id"].intValue), key: "id")
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let topVC = storyboard.instantiateInitialViewController()
                    topVC?.modalTransitionStyle = .flipHorizontal
                    self.present(topVC!, animated: true, completion: nil)
                    
                }.catch { err in
                    self.indicator.stopIndicator()
                    
                    let tmp_err = err as NSError
                    self.present(GetStandardAlert(title: "Error", message: tmp_err.domain, b_title: "OK"), animated: true, completion: nil)
            }
        }else {
            self.present(GetStandardAlert(title: "Error", message: "入力項目を再確認してください", b_title: "OK"), animated: true, completion: nil)
        }
    }
    
    func CallSaveUUIDAPI() -> Promise<String> {
        let uuid = NSUUID().uuidString
        let sensor_set = form.values()["sensor_set"] as! Bool
        
        if !sensor_set {
            let promise = Promise<String> { (resolve, reject) in
                resolve(uuid)
            }
            return promise
        }
        
        let promise = Promise<String> { (resolve, reject) in
            let address = form.values()["address"] as! String
            let request = GetConnectRaspberryPIRequest(method: "POST", address: address, uuid: uuid)
            
            Alamofire.request(request).responseJSON { response in
                guard let obj = response.result.value else {return reject(NSError(domain: "センサーに接続できませんでした", code: -1))}
                let json = JSON(obj)
                
                print("***** raspi results *****")
                print(json)
                print(response.error)
                print("***** raspi results *****")
                
                if response.error == nil {
                    resolve(json["uuid"].stringValue)
                }else {
                    reject(NSError(domain: "センサーに接続できませんでした", code: -1))
                }
            }
            
        }
        
        return promise
    }
    
    func CallCreateUserAPI(uuid: String) -> Promise<JSON> {
        var values = form.values()
        var address = ""
        if values["sensor_set"] as! Bool {
            address = values["address"] as! String
        }
        
        let params = [
            "uuid": uuid,
            "payday": values["payday"] as! Int,
            "price": values["price"] as! Int,
            "target_number": values["target_number"] as! Int,
            "address": address
            ] as [String : Any]
        
        let promise = Promise<JSON> { (resolve, reject) in
            let urlString = API.base.rawValue + API.v1.rawValue + API.user.rawValue
            Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                guard let obj = response.result.value else {return}
                let json = JSON(obj)
                
                print("***** API results *****")
                print(json)
                print("***** API results *****")
                
                if response.error == nil {
                    resolve(json)
                }else {
                    reject(response.error!)
                }
            }
        }
        
        return promise
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
