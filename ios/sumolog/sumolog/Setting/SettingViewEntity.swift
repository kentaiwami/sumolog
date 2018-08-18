//
//  SettingViewEntity.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserData {
    struct UserData {
        var payday = 0
        var price = 0
        var target_number = 0
        var address = ""
        var uuid_count = 0
    }
    
    private var data = UserData()
    
    func setUUIDCount(count: Int) {
        data.uuid_count = count
    }
    
    func getpayday() -> Int {
        return data.payday
    }
    
    func getprice() -> Int {
        return data.price
    }
    
    func gettarget_number() -> Int {
        return data.target_number
    }
    
    func getaddress() -> String {
        return data.address
    }
    
    func getCount() -> Int {
        return data.uuid_count
    }
    
    func setAll(json: JSON) {
        data.payday = json["payday"].intValue
        data.price = json["price"].intValue
        data.target_number = json["target_number"].intValue
        data.address = json["address"].stringValue
    }
}
