//
//  SmokeListEditViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol SmokeListEditViewInterface: class {
    var start: Date { get }
    var end: Date { get }
    
    func popView()
    func showAlert(title: String, msg: String)
}

class SmokeListEditViewController: FormViewController,  SmokeListEditViewInterface {
    var start: Date {
        return form.values()["start"] as! Date
    }
    
    var end: Date {
        return form.values()["end"] as! Date
    }
    
    fileprivate var presenter: SmokeListEditViewPresenter!
    
    fileprivate let utility = Utility()
    
    // インスタンス化された際に値を一時保存
    var tmpStart = ""
    var tmpEnd = ""
    var tmpID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "編集"
        tableView.isScrollEnabled = false
        initializePresenter()
        presenter.setSmokeInfo(start: tmpStart, end: tmpEnd, ID: tmpID)
        createForms()
    }
    
    private func createForms() {
        let dateFormatterSec = utility.getDateFormatter(format: "yyyy-MM-dd HH:mm:ss")
        let dateFormatterMin = utility.getDateFormatter(format: "yyyy-MM-dd HH:mm")
        
        var end_row_value = dateFormatterSec.date(from: presenter.getSmokeTime().end)
        if presenter.isEndedAtEmpty() {
            end_row_value = nil
        }
        
        var rules = RuleSet<Date>()
        rules.add(rule: RuleRequired(msg: "必須項目です"))
        
        form +++ Section("喫煙時間")
            <<< DateTimeRow(){
                $0.title = "開始"
                $0.value = dateFormatterSec.date(from: presenter.getSmokeTime().start)
                $0.tag = "start"
                $0.dateFormatter = dateFormatterMin
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            
            <<< DateTimeRow(){
                $0.title = "終了"
                $0.value = end_row_value
                $0.tag = "end"
                $0.dateFormatter = dateFormatterMin
                $0.add(ruleSet: rules)
                $0.validationOptions = .validatesOnChange
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            .onRowValidationChanged {cell, row in
                self.utility.showRowError(row: row)
            }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "更新"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                $0.tag = "update"
                }
                .onCellSelection {  cell, row in
                    if self.utility.isCheckFormValue(form: self.form){
                        let start = self.form.values()["start"] as! Date
                        let end = self.form.values()["end"] as! Date
                        
                        if start > end {
                            self.utility.showStandardAlert(title: "エラー", msg: "終了時間は開始時間よりも後の時刻を設定してください。", vc: self, completion: nil)
                        }else {
                            if self.presenter.isEndedAtEmpty() {
                                let popup = PopupDialog(title: "警告", message: "センサーを利用している場合は、センサーが計測中である可能性があります。編集を実行した場合、センサーの再起動が必要になります。また、センサーによって値が上書きされる可能性があります。\nそれでもよろしいですか？")
                                let cancel = CancelButton(title: "キャンセル") {}
                                let ok = DefaultButton(title: "OK", action: {
                                    self.presenter.updateSmoke(isReset: true)
                                })
                                popup.addButtons([ok, cancel])
                                self.present(popup, animated: true, completion: nil)
                            }else {
                                self.presenter.updateSmoke(isReset: false)
                            }
                        }
                    }else {
                        self.utility.showStandardAlert(title: "エラー", msg: "入力されていない項目があります。再確認してください。", vc: self, completion: nil)
                    }
        }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "削除"
                $0.baseCell.backgroundColor = UIColor.red
                $0.baseCell.tintColor = UIColor.white
                $0.tag = "delete"
                }
                .onCellSelection {  cell, row in
                    var msg = ""
                    
                    if self.presenter.isEndedAtEmpty() {
                        msg = "センサーを利用している場合は、センサーが計測中である可能性があります。削除を実行した場合、センサーの再起動が必要です。\nそれでも削除しますか？"
                    }else {
                        msg = "この喫煙データを削除しますか？"
                    }
                    
                    let popup = PopupDialog(title: "警告", message: msg)
                    let cancel = CancelButton(title: "キャンセル") {}
                    let delete = DestructiveButton(title: "削除", action: {
                        self.presenter.deleteSmoke()
                    })
                    popup.addButtons([delete, cancel])
                    self.present(popup, animated: true, completion: nil)
        }
    }
    
    private func initializePresenter() {
        presenter = SmokeListEditViewPresenter(view: self)
    }
}


// MARK: - インスタンス化の際に呼び出す関数
extension SmokeListEditViewController {
    func setSmokeInfo(start: String, end: String, ID: Int) {
        tmpStart = start
        tmpEnd = end
        tmpID = ID
    }
}

// MARK: - Presenterから呼び出される関数一覧
extension SmokeListEditViewController {
    func popView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
