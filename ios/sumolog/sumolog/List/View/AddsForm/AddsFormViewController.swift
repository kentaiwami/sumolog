//
//  AddsFormViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

protocol AddsFormViewInterface: class {
    var formValues:[String:Any?] { get }
    
    func showAlert(title: String, msg: String)
}

class AddsFormViewController: FormViewController, AddsFormViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: AddsFormViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "一括追加"
        tableView.isScrollEnabled = false
        initializePresenter()
        CreateForm()
        setUpNavigationButton()
    }
    
    private func setUpNavigationButton() {
        let close = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func initializePresenter() {
        presenter = AddsFormViewPresenter(view: self)
    }
    
    private func CreateForm() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        let dateFormatterMin = GetDateFormatter(format: "yyyy-MM-dd HH:mm")
        let dateFormatterTime = GetDateFormatter(format: "HH:mm")

        form +++ Section(header: "時刻の範囲", footer: "")
            <<< DateTimeRow(){
                $0.title = "開始地点"
                $0.value = Date()
                $0.tag = "start"
                $0.dateFormatter = dateFormatterMin
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            
            <<< DateTimeRow(){
                $0.title = "終了地点"
                $0.value = Date()
                $0.tag = "end"
                $0.dateFormatter = dateFormatterMin
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            
        form +++ Section(header: "喫煙情報", footer: "")
            <<< PickerInputRow<Int>(""){
                $0.title = "1本あたりの喫煙時間（分）"
                $0.value = 1
                $0.options = [Int](1...60)
                $0.tag = "time"
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })

            <<< IntRow(){
                $0.title = "本数"
                $0.value = 0
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "number"
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
        

        form +++ Section()
            <<< ButtonRow(){
                $0.title = "追加"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                if IsCheckFormValue(form: self.form) {
                    self.presenter.adds()
                }else {
                    ShowStandardAlert(title: "エラー", msg: "入力項目を再確認してください", vc: self, completion: nil)
                }
            }
    }
}

// MARK: - Presenterから呼び出される関数一覧
extension AddsFormViewController {
    func showAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
