//
//  API.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class API {
    let base = GetHost() + "api/"
    let version = "v1/"
    
    fileprivate func get(url: String) -> Promise<JSON> {
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .get).validate(statusCode: 200..<600).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET API Results *****")
                    print(json)
                    print("***** GET API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) && !json["code"].exists() {
                        seal.fulfill(json)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    fileprivate func URLRequest(url: String, method: String, uuid: String) -> Promise<String> {
        let request = GetConnectRaspberryPIRequest(method: method, urlString: url, uuid: uuid)
        let promise = Promise<String> { seal in
            Alamofire.request(request).validate(statusCode: 200..<600).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET API Results *****")
                    print(json)
                    print("***** GET API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) && !json["code"].exists() {
                        seal.fulfill(json["uuid"].stringValue)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    fileprivate func postPutPatchDeleteAuth(url: String, params: [String:Any], httpMethod: HTTPMethod) -> Promise<JSON> {
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: httpMethod, parameters: params, encoding: JSONEncoding(options: [])).validate(statusCode: 200..<600).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** "+String(httpMethod.rawValue)!+" Auth API Results *****")
                    print(json)
                    print("***** "+String(httpMethod.rawValue)!+" Auth API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) && !json["code"].exists() {
                        seal.fulfill(json)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
}

extension API {
    func saveUUIDInSensor(isSensorSet: Bool, url: String) -> Promise<String> {
        let uuid = NSUUID().uuidString
        
        if !isSensorSet {
            let promise = Promise<String> { seal in
                seal.fulfill(uuid)
            }
            return promise
        }
        
        return URLRequest(url: url, method: "POST", uuid: uuid)
    }
    
    func createUser(params: [String:Any]) -> Promise<JSON> {
        let endPoint = "user"
        return postPutPatchDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .post)
    }
}
