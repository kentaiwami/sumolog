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
    var isempty = false
    
    let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Smoke Edit"
        
        let keychain = Keychain()
        uuid = (try! keychain.getString("uuid"))!
        user_id = (try! keychain.getString("id"))!
        
        CreateForms()
        tableView.isScrollEnabled = false
        
        if ended_at.count == 0 {
            isempty = true
        }
    }
    
    func CreateForms() {        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        form +++ Section("喫煙情報")
            <<< DateTimeRow(){
                $0.title = "Start"
                $0.value = dateFormatter.date(from: started_at)
                $0.tag = "start"
            }
        
            <<< DateTimeRow(){
                $0.title = "End"
                $0.value = dateFormatter.date(from: ended_at)
                $0.tag = "end"
            }
        
        form +++ Section(header: "", footer: "入力された情報で上書きします")
            <<< ButtonRow(){
                $0.title = "更新"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                $0.tag = "update"
            }
            .onCellSelection {  cell, row in
                if self.isempty {
                    self.present(GetOKCancelAlert(title: "警告", message: "センサーが終了時間を計測中のため、編集を実行した場合センサーの再起動が必要になります。また、センサーによって値が上書きされる可能性があります。それでもよろしいですか？", ok_action: {
                        self.CallUpdateSmokeDataAPI()
                    }), animated: true, completion: nil)
                }else {
                    self.CallUpdateSmokeDataAPI()
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
                
                if self.isempty {
                    msg = "センサーが終了時間を計測中のため削除を実行した場合、センサーの再起動が必要です。それでも削除しますか？"
                }else {
                    msg = "この喫煙データを削除しますか？"
                }
                
                self.present(GetDeleteCancelAlert(title: "警告", message: msg, delete_action: {
                    self.CallDeleteSmokeDataAPI()
                }), animated: true, completion: nil)
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
