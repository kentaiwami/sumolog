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
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "ユーザ情報"
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
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1

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
            
            
            <<< DecimalRow(){
                $0.title = "1本の値段"
                $0.value = presenter.getUserData().getprice()
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))
                $0.validationOptions = .validatesOnChange
                $0.formatter = formatter
                $0.tag = "price"
                }
                .onRowValidationChanged {cell, row in
                    self.utility.showRowError(row: row)
            }
            
            
            <<< IntRow(){
                $0.title = "1日の目標本数"
                $0.value = presenter.getUserData().gettarget_number()
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "target_number"
                }
                .onRowValidationChanged {cell, row in
                    self.utility.showRowError(row: row)
            }
        
            <<< SwitchRow(){
                $0.title = "平均時間を使用した記録"
                $0.value = presenter.getUserData().getIsAddAverageAuto()
                $0.tag = "is_auto_add"
        }
        
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "更新"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                }
                .onCellSelection {  cell, row in
                    if self.utility.isCheckFormValue(form: self.form) {
                        self.presenter.updateUserData()
                    }else {
                        self.utility.showStandardAlert(title: "エラー", msg: "入力項目を再確認してください", vc: self, completion: nil)
                    }
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    func doneUpdateUserData(title: String, msg: String) {
        updateCell()
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
