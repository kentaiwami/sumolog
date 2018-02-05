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
import PromiseKit


class SettingViewController: FormViewController {

    var iscreate = false
    var user_data = UserData()
    var uuid = ""
    var user_id = ""
    let keychain = Keychain()
    let indicator = Indicator()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Setting"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
//        UIView.setAnimationsEnabled(false)
//        form.removeAll()
//        UIView.setAnimationsEnabled(true)
//
//        /*
//         1. ユーザの設定情報読み込み
//         2. UUIDの登録状況をデバイスへ問い合わせ
//         3. formの描画
//         */
//        indicator.showIndicator(view: tableView)
//        CallGetSettingAPI().then{_ in
//            return self.CallGetUUIDCountAPI(address: self.user_data.Getaddress())
//            }.then { count -> Void in
//                self.CreateForm(count: count)
//                self.indicator.stopIndicator()
//            }.catch { err in
//                self.indicator.stopIndicator()
//                self.present(GetStandardAlert(title: "Error", message: "センサーへ接続できませんでした", b_title: "OK"), animated: true, completion: nil)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let keychain = Keychain()
        user_id = (try! keychain.getString("id"))!
        uuid = (try! keychain.getString("uuid"))!
        
        tableView.isScrollEnabled = false
        
        indicator.showIndicator(view: tableView)
        
        CallGetUserAPI().then{_ ->Promise<Int> in
            self.CreateForm()
            return self.CallGetUUIDCountAPI()
        }.then { _ -> Void in
            self.indicator.stopIndicator()
        }.catch { err in
            self.indicator.stopIndicator()
            let ns_err = err as NSError
            let alert = GetStandardAlert(title: "Error", message: ns_err.domain, b_title: "OK")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func CreateForm() {
        UIView.setAnimationsEnabled(false)
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        var rules = RuleSet<Int>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        rules.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))
        
        var sensor_set = false
        if !user_data.Getaddress().isEmpty {
            sensor_set = true
        }
        
        form +++ Section(header: "ユーザ情報", footer: "")
            <<< PickerInputRow<Int>(""){
                $0.title = "給与日"
                $0.value = user_data.Getpayday()
                $0.options = GenerateDate()
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "payday"
            }
        
            
            <<< IntRow(){
                $0.title = "1本の値段"
                $0.value = user_data.Getprice()
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
                $0.value = user_data.Gettarget_number()
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
                $0.value = sensor_set
                $0.tag = "sensor_set"
            }
            <<< TextRow(){
                $0.title = "センサーのIPアドレス"
                $0.value = user_data.Getaddress()
                $0.add(rule: RuleRegExp(regExpr: "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}", allowsEmpty: false, msg: "形式を確認してください。ex.) 192.168.0.0"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "address"
                $0.hidden = Condition.function(["sensor_set"], { form in
                    return !((form.rowBy(tag: "sensor_set") as? SwitchRow)?.value ?? false)
                })
            }
            .onRowValidationChanged {cell, row in
                guard let tmp_indexPath = row.indexPath else{return}
                let rowIndex = tmp_indexPath.row
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
        
        
        form +++ Section(header: "", footer: "入力された情報で上書きします")
            <<< ButtonRow(){
                    $0.title = "更新"
                    $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                    $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                self.indicator.showIndicator(view: self.tableView)
                self.CallUpdateUserAPI().then { _ -> Void in
                    self.UpdateCell()
                    self.indicator.stopIndicator()
                    
                    let alert = GetStandardAlert(title: "Success", message: "情報を更新しました", b_title: "OK")
                    self.present(alert, animated: true, completion: nil)
                }.catch{ err in
                    self.UpdateCell()
                    self.indicator.stopIndicator()
                    let ns_err = err as NSError
                    let alert = GetStandardAlert(title: "Error", message: ns_err.domain, b_title: "OK")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        
        
        form +++ Section(header: "連携", footer: "解除した場合、喫煙は記録されません"){ section in
            section.hidden = Condition.function(["sensor_set"], {form in
                return !((form.rowBy(tag: "sensor_set") as? SwitchRow)?.value ?? false)
                })
            }
            <<< SwitchRow("SwitchRow") { row in
                row.tag = "switch"
                row.title = "接続状況"
                row.value = false
            }.onChange { row in
                self.CallSaveDeleteUUIDAPI(value: row.value!, address: self.form.values()["address"] as! String).then { _ -> Void in
                    row.updateCell()
                    }.catch { err in
                        let tmp = err as NSError
                        self.present(GetStandardAlert(title: "Error", message: tmp.domain, b_title: "OK"), animated: true, completion: nil)
                }
            }.cellSetup { cell, row in
                cell.backgroundColor = .white
            }
        
        UIView.setAnimationsEnabled(true)
    }
    
    func UpdateCell() {
        let payday = form.rowBy(tag: "payday")
        let price = form.rowBy(tag: "price")
        let target_number = form.rowBy(tag: "target_number")
        let address = form.rowBy(tag: "address")

        payday?.baseValue = user_data.Getpayday()
        price?.baseValue = user_data.Getprice()
        target_number?.baseValue = user_data.Gettarget_number()
        address?.baseValue = user_data.Getaddress()

        payday?.updateCell()
        price?.updateCell()
        target_number?.updateCell()
        address?.updateCell()
    }
    
    func CallSaveDeleteUUIDAPI(value: Bool, address: String) -> Promise<String> {
        var method = ""
        if value {
            method = "POST"
        }else {
            method = "DELETE"
        }
        
        indicator.showIndicator(view: self.view)
        
        let request = GetConnectRaspberryPIRequest(method: method, address: address, uuid: uuid)
        let promise = Promise<String> { (resolve, reject) in
            Alamofire.request(request).responseJSON { response in
                self.indicator.stopIndicator()
                
                if response.error == nil {
                    guard let obj = response.result.value else {return}
                    let json = JSON(obj)
                    print("***** RasPI results *****")
                    print(json)
                    print("***** RasPI results *****")
                    
                    resolve("OK")
                }else {
                    reject(NSError(domain: "センサーに接続できませんでした", code: -1))
                }
            }
        }
        return promise
    }
    
    func CallUpdateUserAPI() -> Promise<String> {
        if !IsCheckFormValue(form: form) {
            let promise = Promise<String> { (resolve, reject) in
                reject(NSError(domain: "必須項目を入力してください", code: -1))
            }
            return promise
        }
        
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

        let urlString = API.base.rawValue + API.v1.rawValue + API.user.rawValue + user_id
        
        let promise = Promise<String> { (resolve, reject) in
            Alamofire.request(urlString, method: .put, parameters: params, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                guard let obj = response.result.value else {return}
                let json = JSON(obj)
                print("***** API results *****")
                print(json)
                print("***** API results *****")
                self.user_data.SetAll(json: json)
                resolve("OK")
            }
        }
        
        return promise
    }
    
    func CallGetUserAPI() -> Promise<String> {
        let urlString = API.base.rawValue + API.v1.rawValue + API.user.rawValue + user_id
        let promise = Promise<String> { (resolve, reject) in
            Alamofire.request(urlString, method: .get).responseJSON { (response) in
                guard let object = response.result.value else{return}
                let json = JSON(object)
                print("User Setting results: ", json.count)
                print(json)
                
                self.user_data.SetAll(json: json)
                resolve("OK")
            }
        }
        
        return promise
    }
    
    func CallGetUUIDCountAPI() -> Promise<Int> {
        if user_data.Getaddress().isEmpty {
            let promise = Promise<Int> { (resolve, reject) in
                user_data.SetUUIDCount(count: 0)
                resolve(0)
            }
            return promise
        }
        
        let request = GetConnectRaspberryPIRequest(method: "GET", address: user_data.Getaddress(), uuid: uuid)
        let promise = Promise<Int> { (resolve, reject) in
            Alamofire.request(request).responseJSON { response in
                guard let obj = response.result.value else {return reject(NSError(domain: "センサーに接続できませんでした", code: -1))}
                let json = JSON(obj)
                print("***** raspi results *****")
                print(json)
                print(response.error)
                print("***** raspi results *****")
                
                if response.error == nil {
                    self.user_data.SetUUIDCount(count: json["count"].intValue)
                    resolve(json["count"].intValue)
                }else {
                    reject(NSError(domain: "センサーに接続できませんでした", code: -1))
                }
            }
        }
        return promise
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
