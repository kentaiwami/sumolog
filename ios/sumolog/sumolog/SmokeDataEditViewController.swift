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

class SmokeDataEditViewController: FormViewController {

    var uuid = ""
    var smoke_id = 0
    var started_at = ""
    var ended_at = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Smoke Edit"
        
        let keychain = Keychain()
        uuid = (try! keychain.getString("uuid"))!
        
        CreateForms()
        tableView.isScrollEnabled = false
    }
    
    func CreateForms() {
        var rules = RuleSet<String>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        rules.add(rule: RuleRegExp(regExpr: "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}", allowsEmpty: false, msg: "形式が間違っています"))
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        form +++ Section("喫煙情報")
            <<< TextRow(){
                $0.title = "Start Time"
                $0.value = started_at
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
                $0.value = ended_at
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
