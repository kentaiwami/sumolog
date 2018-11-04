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
        var price = 0.0
        var target_number = 0
        var isAddAverageAuto = false
    }
    
    private var data = UserData()
    
    func getpayday() -> Int {
        return data.payday
    }
    
    func getprice() -> Double {
        return data.price
    }
    
    func gettarget_number() -> Int {
        return data.target_number
    }
    
    func getIsAddAverageAuto() -> Bool {
        return data.isAddAverageAuto
    }
    
    func setAll(json: JSON) {
        data.payday = json["payday"].intValue
        data.price = json["price"].doubleValue
        data.target_number = json["target_number"].intValue
        data.isAddAverageAuto = json["is_add_average_auto"].boolValue
    }
}
