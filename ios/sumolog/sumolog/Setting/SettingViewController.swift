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
    private var uuid = ""
    private let keychain = Keychain()
    private let indicator = Indicator()
    private let sign_common = SignCommon()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Setting"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        if iscreate {
            uuid = NSUUID().uuidString
            user_data.Setprice(price: 0)
            user_data.Setpayday(payday: 0)
            user_data.Setaddress(address: "")
            user_data.Settarget_number(target_number: 0)
        }else {
            uuid = (try! keychain.getString("uuid"))!
            
            indicator.showIndicator(view: self.view)
            CallGetSettingAPI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        CreateForm()
        tableView.isScrollEnabled = false
    }
    
    func CallGetSettingAPI() {
        indicator.showIndicator(view: self.view)
        
        let keychain = Keychain()
        let id = try! keychain.getString("id")
        
        let urlString = API.base.rawValue + API.v1.rawValue + API.user.rawValue + id!
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("User Setting results: ", json.count)
            print(json)
            self.user_data.SetAll(json: json)
            
            self.indicator.stopIndicator()
            
            self.UpdateCells()
            
            // ラズパイからレコード数を取得してスイッチに値を設定する
            self.CallUUIDAPI(ischeckform: true, method: "GET", nil_action: {response in
                let obj = JSON(response.result.value as Any)
                let switch_row = self.form.rowBy(tag: "switch")
                if obj["count"].intValue == 0 {
                    switch_row?.baseValue = false
                }else {
                    switch_row?.baseValue = true
                }
                
                switch_row?.updateCell()
                
                print("UUID count: ", obj["count"])
            })
        }
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
        
        form +++ Section(header: "ユーザ情報", footer: "センサーを所持していない場合は、IPアドレスの欄は空にしてください。")
            <<< PickerInputRow<Int>(""){
                $0.title = "給与日"
                $0.value = user_data.Getpayday()
                $0.options = sign_common.GenerateDate()
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "payday"
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
        
            
            <<< SwitchRow("sensor_have"){
                $0.title = "センサーを所持している"
            }
            <<< TextRow(){
                $0.title = "センサーのIPアドレス"
                $0.value = user_data.Getaddress()
                $0.add(rule: RuleRegExp(regExpr: "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}", allowsEmpty: false, msg: "形式を確認してください。ex.) 192.168.0.0"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "address"
                $0.hidden = Condition.function(["sensor_have"], { form in
                    return !((form.rowBy(tag: "sensor_have") as? SwitchRow)?.value ?? false)
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
                            $0.hidden = Condition.function(["sensor_have"], { form in
                                return !((form.rowBy(tag: "sensor_have") as? SwitchRow)?.value ?? false)
                            })
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
        if iscreate {
            CreateButtonRow(action: {
                self.CallUUIDAPI(ischeckform: true, method: "POST", nil_action: {_ in
                    self.CallUpdateCreateUserAPI()
                    try! self.keychain.set(self.uuid, key: "uuid")
                })
                
            }, header: "連携", footer: "この操作を行うと喫煙が記録されます", title: "接続", bgColor: UIColor.hex(Color.main.rawValue, alpha: 1.0), tag: "connect")
        }else {
            CreateButtonRow(action: {self.CallUpdateCreateUserAPI()}, header: "", footer: "入力された情報で上書きします", title: "更新", bgColor: UIColor.hex(Color.main.rawValue, alpha: 1.0), tag: "update")
            
            form +++ Section(header: "連携", footer: "解除した場合、喫煙は記録されません")
                <<< SwitchRow("SwitchRow") { row in
                    row.title = "Connecting"
                    row.value = true
                    row.tag = "switch"
                }.onChange { row in
                    row.title = (row.value ?? false) ? "Connecting" : "Dis Connecting"
                    row.updateCell()
                    self.RunRaspberryPIAPI(value: row.value!)
                }.cellSetup { cell, row in
                    cell.backgroundColor = .white
                }
        }
    }
    
    func RunRaspberryPIAPI(value: Bool) {
        if value {
            CallUUIDAPI(ischeckform: true, method: "POST", nil_action: {_ in
                self.CallUpdateCreateUserAPI()
                try! self.keychain.set(self.uuid, key: "uuid")
            })
        }else {
            CallUUIDAPI(ischeckform: false, method: "DELETE", nil_action: {_ in })
        }
    }
    
    func CreateButtonRow(action: @escaping () -> Void, header: String, footer: String, title: String, bgColor: UIColor, tag: String) {
        form +++ Section(header: header, footer: footer)
            <<< ButtonRow(){
                $0.title = title
                $0.baseCell.backgroundColor = bgColor
                $0.baseCell.tintColor = UIColor.white
                $0.tag = tag
        }
        .onCellSelection {  cell, row in
            action()
        }
    }
    
    func UpdateCells() {
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
    
    func SetisCreate(iscreate: Bool) {
        self.iscreate = iscreate
    }
    
    func CallUpdateCreateUserAPI() {
        indicator.showIndicator(view: self.view)
        
        var id = ""
        var method = HTTPMethod.post
        if !iscreate {
            method = HTTPMethod.put
            id = (try! keychain.getString("id"))!
        }
        
        if sign_common.IsCheckFormValue(form: form) {
            var values = form.values()
            values["uuid"] = uuid
            
            let urlString = API.base.rawValue + API.v1.rawValue + API.user.rawValue + id
            Alamofire.request(urlString, method: method, parameters: values, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                self.indicator.stopIndicator()
                
                let obj = JSON(response.result.value)
                print("***** API results *****")
                print(obj)
                print("***** API results *****")
                
                if self.iscreate {
                    try! self.keychain.set(String(obj["id"].intValue), key: "id")
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let topVC = storyboard.instantiateInitialViewController()
                    topVC?.modalTransitionStyle = .flipHorizontal
                    self.present(topVC!, animated: true, completion: nil)
                }
            }

        }else {
            self.indicator.stopIndicator()
            present(GetStandardAlert(title: "エラー", message: "必須項目を入力してください", b_title: "OK"), animated: true, completion: nil)
        }
    }
    
    func CallUUIDAPI(ischeckform: Bool, method: String, nil_action: @escaping (DataResponse<Any>) -> Void) {
        indicator.showIndicator(view: self.view)
        
        let request = GetConnectRaspberryPIRequest(method: method)
        var tmpFunc_json = {(response: DataResponse<Any>) -> Void in}
        var tmpFunc_string = {(response: DataResponse<String>) -> Void in}
        
        switch method {
        case "GET", "POST":
            tmpFunc_json = {response in
                self.indicator.stopIndicator()
                
                print("***** raspi results *****")
                print(JSON(response.result.value))
                print(response.error)
                print("***** raspi results *****")
                
                if response.error == nil {
                    nil_action(response)
                }else {
                    self.present(GetStandardAlert(title: "通信エラー", message: "指定したアドレスに接続できませんでした", b_title: "OK"), animated: true, completion: nil)
                }
            }
            break
        case "DELETE":
            tmpFunc_string = {response in
                self.indicator.stopIndicator()
                
                print("***** raspi results *****")
                print(response.error)
                print("***** raspi results *****")
                
                if response.error != nil {
                    self.present(GetStandardAlert(title: "通信エラー", message: "指定したアドレスに接続できませんでした", b_title: "OK"), animated: true, completion: nil)
                }
            }
            break
        default:
            break
        }
        
        // APIをたたく
        if ischeckform {
            if sign_common.IsCheckFormValue(form: form) {
                Alamofire.request(request).responseJSON { response in
                    tmpFunc_json(response)
                }
            }else {
                self.indicator.stopIndicator()
                self.present(GetStandardAlert(title: "エラー", message: "必須項目を入力してください", b_title: "OK"), animated: true, completion: nil)
            }
        }else {
            Alamofire.request(request).responseString { response in
                tmpFunc_string(response)
            }
        }
    }
    
    func GetConnectRaspberryPIRequest(method: String) -> URLRequest {
        let address = form.values()["address"] as! String
        let urlString = "http://" + address + "/api/v1/user"
        let tmp_req = ["uuid": uuid]
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = try! JSONSerialization.data(withJSONObject: tmp_req, options: [])
        
        return request
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
