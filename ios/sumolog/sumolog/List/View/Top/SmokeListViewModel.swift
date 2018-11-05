//
//  SmokeListViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol SmokeListViewModelDelegate: class {
    func drawView()
    func success(title: String, msg: String)
    func faildAPI(title: String, msg: String)
}

class SmokeListViewModel {
    weak var delegate: SmokeListViewModelDelegate?
    private let api = API()
    private let keychain = Keychain()
    
    private(set) var results:[JSON] = []
    
    func setSmokeState() {
        let is_smoking = try! keychain.getString("is_smoking")
        let smoke_id = try! keychain.getString("smoke_id")
        
        if is_smoking == nil {
            try! keychain.set(String(false), key: "is_smoking")
        }
        
        if smoke_id == nil {
            try! keychain.set("", key: "smoke_id")
        }
    }
    
    func getIsSmoking() -> Bool {
        return NSString(string: (try! keychain.getString("is_smoking"))!).boolValue
    }
    
    func getResults() -> [JSON] {
        return results
    }
    
    func setResults(isShowIndicator: Bool) {
        let userID = try! keychain.get("id")!
        
        api.get24HourSmoke(isShowIndicator: isShowIndicator, userID: userID).done { (json) in
            self.results = json["results"].arrayValue
            self.delegate?.drawView()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getEndNullCount() -> Int {
        return results.filter({$0["ended_at"].stringValue.isEmpty}).count
    }
    
    func startSmoke() {
        let uuid = (try! keychain.get("uuid"))!
        print("++++++++++++++++++++++++++++")
        print(uuid)
        print("++++++++++++++++++++++++++++")
        let params = [
            "uuid": uuid,
            "is_sensor": false
            ] as [String : Any]
        
        api.startSmoke(params: params).done { (json) in
            if json["is_add_average_auto"].boolValue {
                self.delegate?.success(title: "成功", msg: "平均時間を使用して喫煙を記録しました。")
            }else {
                try! self.keychain.set(String(json["smoke_id"].intValue), key: "smoke_id")
                try! self.keychain.set(String(true), key: "is_smoking")
                self.delegate?.success(title: "成功", msg: "喫煙開始を記録しました。\n右上のチェックボタンをタップして喫煙終了を記録してください。")
            }
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func endSmoke() {
        let smokeID = (try! keychain.getString("smoke_id"))!
        let uuid = (try! keychain.get("uuid"))!
        let params = [
            "uuid": uuid,
            "minus_sec": 0,
            "is_sensor": false
            ] as [String : Any]
        
        api.endSmoke(params: params, smokeID: smokeID).done { (json) in
            try! self.keychain.set("", key: "smoke_id")
            try! self.keychain.set(String(false), key: "is_smoking")
            self.delegate?.success(title: "成功", msg: "喫煙終了を記録しました。")
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
