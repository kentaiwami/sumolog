//
//  SignCommon.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/02/02.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

class SignCommon {
    
    func GenerateDate() -> Array<Int> {
        var date_array:[Int] = []
        for i in 1...31 {
            date_array.append(i)
        }
        
        return date_array
    }
    
    func IsCheckFormValue(form: Form) -> Bool {
        var err_count = 0
        for row in form.allRows {
            err_count += row.validate().count
        }
        
        if err_count == 0 {
            return true
        }
        
        return false
    }
    
    func GetConnectRaspberryPIRequest(method: String, address: String, uuid: String) -> URLRequest {
        let urlString = "http://" + address + "/api/v1/user"
        let tmp_req = ["uuid": uuid]
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = try! JSONSerialization.data(withJSONObject: tmp_req, options: [])
        
        return request
    }
}
