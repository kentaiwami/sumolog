//
//  SmokeDataFormViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/06.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import KeychainAccess
import SwiftyJSON
import Alamofire

class SmokeDataEditViewController: FormViewController {

    var uuid = ""
    var user_id = ""
    var smoke_id = 0
    var started_at = ""
    var ended_at = ""
    
    let indicator = Indicator()
    let keychain = Keychain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Smoke Edit"
        
        uuid = (try! keychain.getString("uuid"))!
        user_id = (try! keychain.getString("id"))!
        
        CreateForms()
        tableView.isScrollEnabled = false
    }
    
    func CreateForms() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        let dateFormatterSec = GetDateFormatter(format: "yyyy-MM-dd HH:mm:ss")
        let dateFormatterMin = GetDateFormatter(format: "yyyy-MM-dd HH:mm")
        
        var end_row_value = dateFormatterSec.date(from: ended_at)
        if ended_at.isEmpty {
            end_row_value = nil
        }
        
        var rules = RuleSet<Date>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        
        form +++ Section("喫煙時間")
            <<< DateTimeRow(){
                $0.title = "Start"
                $0.value = dateFormatterSec.date(from: started_at)
                $0.tag = "start"
                $0.dateFormatter = dateFormatterMin
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
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
        
            <<< DateTimeRow(){
                $0.title = "End"
                $0.value = end_row_value
                $0.tag = "end"
                $0.dateFormatter = dateFormatterMin
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
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
        
        form +++ Section(header: "", footer: "入力された情報で上書きします")
            <<< ButtonRow(){
                $0.title = "更新"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                $0.tag = "update"
            }
            .onCellSelection {  cell, row in
                if IsCheckFormValue(form: self.form) {
                    if self.ended_at.isEmpty {
                        self.present(GetOKCancelAlert(title: "警告", message: "センサーを利用している場合は、センサーが計測中である可能性があります。編集を実行した場合、センサーの再起動が必要になります。また、センサーによって値が上書きされる可能性があります。\nそれでもよろしいですか？", ok_action: {
                            self.CallUpdateSmokeDataAPI()
                            self.ResetKeyChainValues()
                        }), animated: true, completion: nil)
                    }else {
                        self.CallUpdateSmokeDataAPI()
                    }
                }else {
                    let alert = GetStandardAlert(title: "Error", message: "入力されていない項目があります。再確認してください。", b_title: "OK")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        
        form +++ Section(header: "", footer: "この喫煙データを削除します")
            <<< ButtonRow(){
                $0.title = "削除"
                $0.baseCell.backgroundColor = UIColor.red
                $0.baseCell.tintColor = UIColor.white
                $0.tag = "delete"
            }
            .onCellSelection {  cell, row in
                var msg = ""
                
                if self.ended_at.count == 0 {
                    msg = "センサーを利用している場合は、センサーが計測中である可能性があります。削除を実行した場合、センサーの再起動が必要です。\nそれでも削除しますか？"
                }else {
                    msg = "この喫煙データを削除しますか？"
                }
                
                self.present(GetDeleteCancelAlert(title: "警告", message: msg, delete_action: {
                    self.CallDeleteSmokeDataAPI()
                    self.ResetKeyChainValues()
                }), animated: true, completion: nil)
            }
    }
    
    func ResetKeyChainValues() {
        // 削除 or 編集したデータと手動で記録した喫煙中のデータが同じであった場合にフラグなどをリセット
        let keychain_smoke_id = Int((try! self.keychain.get("smoke_id"))!)
        
        if let keychain_smoke_id = keychain_smoke_id {
            if keychain_smoke_id == self.smoke_id {
                try! self.keychain.set("", key: "smoke_id")
                try! self.keychain.set(String(false), key: "is_smoking")
            }
        }
    }
    
    func CallUpdateSmokeDataAPI() {
        indicator.showIndicator(view: self.view)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let req = [
            "uuid": uuid,
            "started_at": dateFormatter.string(from: form.values()["start"] as! Date),
            "ended_at": dateFormatter.string(from: form.values()["end"] as! Date)
        ]
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + String(smoke_id)
        Alamofire.request(urlString, method: .patch, parameters: req, encoding: JSONEncoding(options: [])).responseJSON { (response) in
            self.indicator.stopIndicator()

            let obj = JSON(response.result.value)
            print("***** Update Smoke data results *****")
            print(obj)
            print("***** Update Smoke data results *****")

            // 終了時間を編集したsmoke dataと手動で喫煙開始をしたsmoke dataが同じであればフラグをfalseにする
            let keychain = Keychain()
            let smoke_id = String((try! keychain.getString("smoke_id"))!)

            if smoke_id! == String(self.smoke_id) {
                try! keychain.set(String(false), key: "is_smoking")
                try! keychain.set("", key: "smoke_id")
            }

            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func CallDeleteSmokeDataAPI() {
        indicator.showIndicator(view: self.view)
        
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + String(smoke_id) + "/" + API.user.rawValue + user_id
        Alamofire.request(urlString, method: .delete, parameters: [:], encoding: JSONEncoding(options: [])).responseJSON { (response) in
            self.indicator.stopIndicator()
            
            let obj = JSON(response.result.value)
            print("***** Delete Smoke data results *****")
            print(obj)
            print("***** Delete Smoke data results *****")
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func SetSmokeID(id: Int) {
        smoke_id = id
    }
    
    func SetStartedAt(started_at: String) {
        self.started_at = started_at
    }
    
    func SetEndedAt(ended_at: String) {
        self.ended_at = ended_at
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
