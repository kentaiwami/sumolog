//
//  SensorSettingViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

protocol SensorSettingViewInterface: class {
    var formValues:[String:Any?] { get }

    func createForm()
    func updateSwitchCell()
    func doneUpdateSensorData(title: String, msg: String)
    func showAlert(title: String, msg: String)
    func faildUpdateSensor(title: String, msg: String)
}

class SensorSettingViewController: FormViewController, SensorSettingViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }

    fileprivate var presenter: SensorSettingViewPresenter!
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "センサー"
        presenter.setSensorData()
    }

    private func initializePresenter() {
        presenter = SensorSettingViewPresenter(view: self)
    }

    fileprivate func updateCell() {
        let address = form.rowBy(tag: "address")
        address?.baseValue = presenter.getSensorData().getaddress()
        address?.updateCell()
    }
}

// MARK: - Presenterから呼び出される関数一覧
extension SensorSettingViewController {
    func createForm() {
        UIView.setAnimationsEnabled(false)

        form.removeAll()
        
        var rules = RuleSet<Int>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        rules.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))

        var sensor_set = false
        if !presenter.isAddressEmpty() {
            sensor_set = true
        }

        form +++ Section(header: "ユーザ情報", footer: "")
            <<< SwitchRow(){
                $0.title = "センサーを設置済み"
                $0.value = sensor_set
                $0.tag = "sensor_set"
            }
            <<< TextRow(){
                $0.title = "センサーのIPアドレス"
                $0.value = presenter.getSensorData().getaddress()
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
                                $0.cell.contentView.backgroundColor = UIColor.red
                                $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                                $0.cell.textLabel?.textAlignment = .right
                                $0.hidden = Condition.function(["sensor_set"], { form in
                                    return !((form.rowBy(tag: "sensor_set") as? SwitchRow)?.value ?? false)
                                })
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
                    if self.utility.isCheckFormValue(form: self.form) {
                        self.presenter.updateSensorData()
                    }else {
                        self.utility.showStandardAlert(title: "エラー", msg: "入力項目を再確認してください", vc: self, completion: nil)
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
                    if self.presenter.getIsTapped() {
                        self.presenter.updateSensorConnection()
                    }else {
                        self.presenter.setIsTapped(value: true)
                    }
                    
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

    func doneUpdateSensorData(title: String, msg: String) {
        updateCell()
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }

    func showAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func faildUpdateSensor(title: String, msg: String) {
        presenter.setIsTapped(value: false)
        updateSwitchCell()
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
