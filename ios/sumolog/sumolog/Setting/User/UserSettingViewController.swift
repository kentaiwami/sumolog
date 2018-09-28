//
//  UserSettingViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

protocol UserSettingViewInterface: class {
    var formValues:[String:Any?] { get }
    
    func createForm()
    func doneUpdateUserData(title: String, msg: String)
    func showAlert(title: String, msg: String)
}

class UserSettingViewController: FormViewController, UserSettingViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    fileprivate var presenter: UserSettingViewPresenter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "設定"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        presenter.setUserData()
    }
    
    private func initializePresenter() {
        presenter = UserSettingViewPresenter(view: self)
    }
    
    fileprivate func updateCell() {
        let payday = form.rowBy(tag: "payday")
        let price = form.rowBy(tag: "price")
        let target_number = form.rowBy(tag: "target_number")
        
        payday?.baseValue = presenter.getUserData().getpayday()
        price?.baseValue = presenter.getUserData().getprice()
        target_number?.baseValue = presenter.getUserData().gettarget_number()
        
        payday?.updateCell()
        price?.updateCell()
        target_number?.updateCell()
    }
}

// MARK: - Presenterから呼び出される関数一覧
extension UserSettingViewController {
    func createForm() {
        UIView.setAnimationsEnabled(false)
        
        form.removeAll()
        
        var rules = RuleSet<Int>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        rules.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))
        
        form +++ Section(header: "ユーザ情報", footer: "")
            <<< PickerInputRow<Int>(""){
                $0.title = "給与日"
                $0.value = presenter.getUserData().getpayday()
                $0.options = [Int](1...31)
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "payday"
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            
            
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
                                $0.cell.contentView.backgroundColor = UIColor.red
                                $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                                $0.cell.textLabel?.textAlignment = .right
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                            })
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
                                $0.cell.contentView.backgroundColor = UIColor.red
                                $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                                $0.cell.textLabel?.textAlignment = .right
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                            })
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
        
        form +++ Section("")
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
        
        UIView.setAnimationsEnabled(true)
    }
    
    func doneUpdateUserData(title: String, msg: String) {
        updateCell()
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
