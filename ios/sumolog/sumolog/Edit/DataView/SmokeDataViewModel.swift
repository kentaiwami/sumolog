//
//  SmokeDataViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol SmokeDataViewModelDelegate: class {
    func drawView()
    func successStartSmoke()
    func successEndSmoke()
    func faildAPI(title: String, msg: String)
}

class SmokeDataViewModel {
    weak var delegate: SmokeDataViewModelDelegate?
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
        api.get24HourSmoke(isShowIndicator: isShowIndicator).done { (json) in
            self.results = json["results"].arrayValue
            self.delegate?.drawView()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getEndNullCount() -> Int {
        return results.filter({$0["ended_at"].stringValue.isEmpty}).count
    }
    
    func startSmoke() {
        api.startSmoke().done { (json) in
            try! self.keychain.set(String(json["smoke_id"].intValue), key: "smoke_id")
            try! self.keychain.set(String(true), key: "is_smoking")
            self.delegate?.successStartSmoke()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func endSmoke() {
        api.endSmoke().done { (json) in
            try! self.keychain.set("", key: "smoke_id")
            try! self.keychain.set(String(false), key: "is_smoking")
            self.delegate?.successEndSmoke()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
