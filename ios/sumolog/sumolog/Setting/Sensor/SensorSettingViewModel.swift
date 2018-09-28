//
//  SensorSettingViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol SensorSettingViewModelDelegate: class {
    func successGetSensorData()
    func successUpdateUUIDCount()
    func doneUpdateSensorData(title: String, msg: String)
    func faildAPI(title: String, msg: String)
    func faildUpdateSensor(title: String, msg: String)
}

class SensorSettingViewModel {
    weak var delegate: SensorSettingViewModelDelegate?
    private let api = API()
    private let keychain = Keychain()
    private(set) var sensorData = SensorData()
    private(set) var isTapped = true
    
    func setIsTapped(value: Bool) {
        isTapped = value
    }
    
    func setSensorData() {
        let userID = (try! keychain.getString("id"))!

        api.getUserData(userID: userID).done { (json) in
            self.sensorData.setAll(json: json)
            self.delegate?.successGetSensorData()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func isAddressEmpty() -> Bool {
        return sensorData.getaddress().isEmpty
    }
    
    func isSensorConnection() -> Bool {
        if sensorData.getCount() == 0 {
            return false
        }else {
            return true
        }
    }
    
    func setUUIDCount() {
        if isAddressEmpty() {
            updateUUIDCount(countUUID: 0)
        }else {
            api.getUUIDCount(address: sensorData.getaddress()).done { (count) in
                self.updateUUIDCount(countUUID: count)
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "エラー(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
            }
        }
    }
    
    func updateSensorData(formValues: [String:Any?]) {
        var address = ""
        if formValues["sensor_set"] as! Bool {
            address = formValues["address"] as! String
        }
        
        let uuid = (try! keychain.get("uuid"))!
        let userID = try! keychain.get("id")!
        
        let params = [
            "uuid": uuid,
            "address": address
            ] as [String : Any]
        
        api.updateSensorData(params: params, userID: userID).done { (json) in
            self.sensorData.setAll(json: json)
            self.delegate?.doneUpdateSensorData(title: "成功", msg: "情報を更新しました")
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.doneUpdateSensorData(title: title, msg: tmp_err.domain)
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
        api.updateUUID(address: sensorData.getaddress(), method: method, uuid: uuid).done { (_) in
            self.updateUUIDCount(countUUID: countUUID)
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            
            if connection {
                self.sensorData.setUUIDCount(count: 0)
            }else {
                self.sensorData.setUUIDCount(count: 1)
            }
            
            self.delegate?.faildUpdateSensor(title: title, msg: tmp_err.domain)
        }
    }
}


extension SensorSettingViewModel {
    fileprivate func updateUUIDCount(countUUID: Int) {
        sensorData.setUUIDCount(count: countUUID)
        delegate?.successUpdateUUIDCount()
    }
}
