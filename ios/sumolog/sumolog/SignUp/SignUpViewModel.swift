//
//  SignUpViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol SignUpViewModelDelegate: class {
    func successSignUp()
    func faildAPI(title: String, msg: String)
}

class SignUpViewModel {
    weak var delegate: SignUpViewModelDelegate?
    private let api = API()
    private let keychain = Keychain()
    
    func signUp(formValues: [String:Any?]) {
        var address = ""
        let isSensorSet = formValues["sensor_set"] as! Bool
        if isSensorSet {
            address = formValues["address"] as! String
        }
        let url = "http://" + address + "/api/v1/user"
        
        api.saveUUIDInSensor(isSensorSet: isSensorSet, url: url).then { uuid -> Promise<JSON> in
            let params = [
                "uuid": uuid,
                "payday": formValues["payday"] as! Int,
                "price": formValues["price"] as! Double,
                "target_number": formValues["target_number"] as! Int,
                "address": address
                ] as [String : Any]

            return self.api.createUser(params: params)
            }.done { json in
                try! self.keychain.set(json["uuid"].stringValue, key: "uuid")
                try! self.keychain.set(String(json["id"].intValue), key: "id")
                try! self.keychain.set(String(false), key: "is_smoking")
                try! self.keychain.set("", key: "smoke_id")
                
                self.delegate?.successSignUp()
            }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
