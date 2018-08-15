//
//  SettingViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol SettingViewModelDelegate: class {
    func successGetUserData()
    func successUpdateUUIDCount()
    func doneUpdateUserData(title: String, msg: String)
    func faildAPI(title: String, msg: String)
}

class SettingViewModel {
    weak var delegate: SettingViewModelDelegate?
    private let api = API()
    private let keychain = Keychain()
    private(set) var userData = UserData()
    
    func setUserData() {
        api.getUserData().done { (json) in
            self.userData.setAll(json: json)
            self.delegate?.successGetUserData()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func isAddressEmpty() -> Bool {
        return userData.getaddress().isEmpty
    }
    
    func isSensorConnection() -> Bool {
        if userData.getCount() == 0 {
            return false
        }else {
            return true
        }
    }
    
    func setUUIDCount() {
        if isAddressEmpty() {
            updateUUIDCount(countUUID: 0)
        }else {
            api.getUUIDCount(address: userData.getaddress()).done { (count) in
                self.updateUUIDCount(countUUID: count)
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
            }
        }
    }
    
    func updateUserData(formValues: [String:Any?]) {
        var address = ""
        if formValues["sensor_set"] as! Bool {
            address = formValues["address"] as! String
        }
        
        let uuid = (try! keychain.get("uuid"))!
        let userID = try! keychain.get("id")!
        
        let params = [
            "uuid": uuid,
            "payday": formValues["payday"] as! Int,
            "price": formValues["price"] as! Int,
            "target_number": formValues["target_number"] as! Int,
            "address": address
            ] as [String : Any]
        
        api.updateUserData(params: params, userID: userID).done { (json) in
            self.userData.setAll(json: json)
            self.delegate?.doneUpdateUserData(title: "成功", msg: "情報を更新しました")
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.doneUpdateUserData(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateSensorConnection(connection: Bool) {
        var method = ""
        var countUUID = 0
        
        if connection {
            method = "POST"
            countUUID = 1
        }else {
            method = "DELETE"
            countUUID = 0
        }
        
        let uuid = (try! keychain.get("uuid"))!
        api.updateUUID(address: userData.getaddress(), method: method, uuid: uuid).done { (_) in
            self.updateUUIDCount(countUUID: countUUID)
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.doneUpdateUserData(title: title, msg: tmp_err.domain)
        }
    }
}


extension SettingViewModel {
    fileprivate func updateUUIDCount(countUUID: Int) {
        userData.setUUIDCount(count: countUUID)
        delegate?.successUpdateUUIDCount()
    }
}
