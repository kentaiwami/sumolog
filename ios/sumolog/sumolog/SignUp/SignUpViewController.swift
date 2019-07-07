//
//  SignUpViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

protocol SignUpViewInterface: class {
    var formValues:[String:Any?] { get }
    
    func navigateTopView()
    func showAlert(title: String, msg: String)
}

class SignUpViewController: FormViewController, SignUpViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: SignUpViewPresenter!
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "サインアップ"
        tableView.isScrollEnabled = false
        initializePresenter()
        CreateForm()
    }
    
    private func initializePresenter() {
        presenter = SignUpViewPresenter(view: self)
    }
    
    private func CreateForm() {
        var rules = RuleSet<Int>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        rules.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        
        form +++ Section(header: "ユーザ情報", footer: "")
            <<< PickerInputRow<Int>(""){
                $0.title = "給与日"
                $0.value = 25
                $0.options = [Int](1...31)
                $0.tag = "payday"
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })


            <<< DecimalRow(){
                $0.title = "1本の値段"
                $0.value = 0.0
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
                $0.value = 0
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
                $0.tag = "target_number"
            }
            .onRowValidationChanged {cell, row in
                self.utility.showRowError(row: row)
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
                self.utility.showRowError(row: row)
            }


        form +++ Section()
            <<< ButtonRow(){
                $0.title = "サインアップ"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                if self.utility.isCheckFormValue(form: self.form) {
                    self.presenter.signUp()
                }else {
                    self.utility.showStandardAlert(title: "エラー", msg: "入力項目を再確認してください", vc: self, completion: nil)
                }
            }
    }


}

// MARK: - Presenterから呼び出される関数一覧
extension SignUpViewController {
    func navigateTopView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let topVC = storyboard.instantiateInitialViewController()
        topVC?.modalTransitionStyle = .flipHorizontal
        self.present(topVC!, animated: true, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
