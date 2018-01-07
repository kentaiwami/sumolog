//
//  SmokeDataCreateViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/08.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import KeychainAccess
import SwiftyJSON
import Alamofire

class SmokeDataCreateViewController: FormViewController {

    var uuid = ""
    let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Smoke Create"
        
        let keychain = Keychain()
        uuid = (try! keychain.getString("uuid"))!
        
        CreateForms()
    }
    
    func CreateForms() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let now = formatter.string(from: Date())
        
        var rules = RuleSet<String>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        rules.add(rule: RuleRegExp(regExpr: "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}", allowsEmpty: false, msg: "形式を確認してください。ex.) 2017-02-04 01:03:04"))
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        form +++ Section("喫煙情報")
            <<< TextRow(){
                $0.title = "Start Time"
                $0.value = now
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "start"
            }.onRowValidationChanged {cell, row in
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
            
            
            <<< TextRow(){
                $0.title = "End Time"
                $0.value = now
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "end"
            }.onRowValidationChanged {cell, row in
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
        
        
        form +++ Section(header: "", footer: "入力された情報で新規作成します")
            <<< ButtonRow(){
                $0.title = "作成"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                $0.tag = "create"
            }
            .onCellSelection {  cell, row in
                self.CallCreateSmokeDataAPI()
            }
    }
    
    func CallCreateSmokeDataAPI() {
        indicator.showIndicator(view: self.view)
        
        var err_count = 0
        for row in form.allRows {
            err_count += row.validate().count
        }
        
        if err_count == 0 {
            let req = [
                "uuid": uuid,
                "started_at": form.values()["start"] as! String,
                "ended_at": form.values()["end"] as! String
            ]
            let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + API.all.rawValue
            Alamofire.request(urlString, method: .post, parameters: req, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                self.indicator.stopIndicator()
                
                let obj = JSON(response.result.value)
                print("***** Create Smoke data results *****")
                print(obj)
                print("***** Create Smoke data results *****")
                
                self.navigationController?.popViewController(animated: true)
            }
        }else {
            self.indicator.stopIndicator()
            self.present(GetStandardAlert(title: "エラー", message: "入力項目を確認してください", b_title: "OK"), animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
