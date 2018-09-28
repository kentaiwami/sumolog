//
//  SensorSettingViewEntity.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/15.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import SwiftyJSON

class SensorData {
    struct SensorData {
        var address = ""
        var uuid_count = 0
    }

    private var data = SensorData()

    func setUUIDCount(count: Int) {
        data.uuid_count = count
    }

    func getaddress() -> String {
        return data.address
    }

    func getCount() -> Int {
        return data.uuid_count
    }

    func setAll(json: JSON) {
        data.address = json["address"].stringValue
    }
}
