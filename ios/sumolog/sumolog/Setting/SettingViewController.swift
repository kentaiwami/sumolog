//
//  SettingViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

protocol SettingViewInterface: class {
    var formValues:[String:Any?] { get }
    
    func createForm()
    func updateSwitchCell()
    func doneUpdateUserData(title: String, msg: String)
    func showAlert(title: String, msg: String)
}

class SettingViewController: FormViewController, SettingViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    fileprivate var presenter: SettingViewPresenter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "設定"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        presenter.setUserData()
    }
    
    private func initializePresenter() {
        presenter = SettingViewPresenter(view: self)
    }
    
    fileprivate func updateCell() {
        let payday = form.rowBy(tag: "payday")
        let price = form.rowBy(tag: "price")
        let target_number = form.rowBy(tag: "target_number")
        let address = form.rowBy(tag: "address")
        
        payday?.baseValue = presenter.getUserData().getpayday()
        price?.baseValue = presenter.getUserData().getprice()
        target_number?.baseValue = presenter.getUserData().gettarget_number()
        address?.baseValue = presenter.getUserData().getaddress()
        
        payday?.updateCell()
        price?.updateCell()
        target_number?.updateCell()
        address?.updateCell()
    }
}

// MARK: - Presenterから呼び出される関数一覧
extension SettingViewController {
    func createForm() {
        UIView.setAnimationsEnabled(false)
        
        form.removeAll()
        
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
        if !presenter.isAddressEmpty() {
            sensor_set = true
        }
        
        form +++ Section(header: "ユーザ情報", footer: "")
            <<< PickerInputRow<Int>(""){
                $0.title = "給与日"
                $0.value = presenter.getUserData().getpayday()
                $0.options = GenerateDate()
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "payday"
            }
            
            
            <<< IntRow(){
                $0.title = "1本の値段"
                $0.value = presenter.getUserData().getprice()
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
                $0.value = presenter.getUserData().gettarget_number()
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
                $0.value = presenter.getUserData().getaddress()
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
                    if IsCheckFormValue(form: self.form) {
                        self.presenter.updateUserData()
                    }else {
                        ShowStandardAlert(title: "エラー", msg: "入力項目を再確認してください", vc: self, completion: nil)
                    }
        }
        
        form +++ Section(header: "連携", footer: "解除した場合、喫煙は記録されません"){ section in
            section.hidden = Condition.function(["sensor_set"], {form in
                return !((form.rowBy(tag: "sensor_set") as? SwitchRow)?.value ?? false)
            })
            }
            <<< SwitchRow("SwitchRow") { row in
                row.tag = "connect"
                row.title = "接続状況"
                row.value = false
                }.onChange { row in
                    self.presenter.updateSensorConnection()
                }.cellSetup { cell, row in
                    cell.backgroundColor = .white
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    func updateSwitchCell() {
        let switch_connect = self.form.rowBy(tag: "connect")
        switch_connect?.baseValue = presenter.isSensorConnection()
        switch_connect?.updateCell()
    }
    
    func doneUpdateUserData(title: String, msg: String) {
        updateCell()
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
