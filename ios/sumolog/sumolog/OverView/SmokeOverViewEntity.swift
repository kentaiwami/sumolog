//
//  SmokeOverViewEntity.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import SwiftyJSON

class SmokeOverViewData {
    struct SmokeOverViewData {
        var count = 0
        var min = 0
        var hour:[[String:Int]] = []
        var over = 0
        var ave = 0.0
        var used = 0
    }

    private var data = SmokeOverViewData()

    func GetCount() -> Int {
        return data.count
    }

    func GetMin() -> Int {
        return data.min
    }

    func GetHour() -> [[String:Int]] {
        return data.hour
    }

    func GetOver() -> Int {
        return data.over
    }

    func GetAve() -> Double {
        return data.ave
    }

    func GetUsed() -> Int {
        return data.used
    }

    func SetAll(json: JSON) {
        data.count = json["count"].intValue
        data.min = json["min"].intValue
        data.over = json["over"].intValue
        data.ave = json["ave"].doubleValue
        data.used = json["used"].intValue

        data.hour.removeAll()
        for obj in json["hour"].arrayValue {
            let tmp = obj.dictionaryValue
            let key = tmp.keys.first!
            data.hour.append([key:tmp[key]!.intValue])
        }
    }
}

