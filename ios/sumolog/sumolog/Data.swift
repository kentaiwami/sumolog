//
//  Data.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/02.
//  Copyright © 2018年 Kenta. All rights reserved.
//
import SwiftyJSON

class UserData {
    struct UserData {
        var payday = 0
        var price = 0
        var target_number = 0
        var address = ""
    }
    
    private var data = UserData()
    
    func Setpayday(payday: Int) {
        data.payday = payday
    }
    
    func Setprice(price: Int) {
        data.price = price
    }
    
    func Settarget_number(target_number: Int) {
        data.target_number = target_number
    }
    
    func Setaddress(address: String) {
        data.address = address
    }
    
    func Getpayday() -> Int {
        return data.payday
    }
    
    func Getprice() -> Int {
        return data.price
    }
    
    func Gettarget_number() -> Int {
        return data.target_number
    }
    
    func Getaddress() -> String {
        return data.address
    }
    
    func SetAll(json: JSON) {
        data.payday = json["payday"].intValue
        data.price = json["price"].intValue
        data.target_number = json["target_number"].intValue
        data.address = json["address"].stringValue
    }
}
