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
import KeychainAccess

class API {
    let base = GetHost() + "api/"
    let version = "v1/"
    
    fileprivate func get(url: String, isShowIndicator: Bool) -> Promise<JSON> {
        let indicator = Indicator()
        
        if isShowIndicator {
            indicator.start()
        }
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .get).validate(statusCode: 200..<600).responseJSON { (response) in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET API Results *****")
                    print(json)
                    print("***** GET API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json)
                    }else {
                        seal.reject(NSError(domain: "エラーが発生しました[-1]", code: (response.response?.statusCode)!))
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
        let indicator = Indicator()
        indicator.start()
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: httpMethod, parameters: params, encoding: JSONEncoding(options: [])).validate(statusCode: 200..<600).responseJSON { (response) in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** "+String(httpMethod.rawValue)!+" Auth API Results *****")
                    print(json)
                    print("***** "+String(httpMethod.rawValue)!+" Auth API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json)
                    }else {
                        seal.reject(NSError(domain: "エラーが発生しました[-1]", code: (response.response?.statusCode)!))
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



// MARK: - Raspi
extension API {
    fileprivate func raspiSignUpRequest(address: String, uuid: String) -> Promise<String> {
        let indicator = Indicator()
        indicator.start()
        
        let request = GetConnectRaspberryPIRequest(method: "POST", address: address, uuid: uuid)
        let promise = Promise<String> { seal in
            Alamofire.request(request).validate(statusCode: 200..<600).responseJSON { response in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET API Results *****")
                    print(json)
                    print("***** GET API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json["uuid"].stringValue)
                    }else {
                        seal.reject(NSError(domain: "センサーに接続できませんでした[-1]", code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "センサーに接続できませんでした[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    fileprivate func raspiUUIDCountRequest(address: String, uuid: String) -> Promise<Int> {
        let indicator = Indicator()
        indicator.start()
        
        let request = GetConnectRaspberryPIRequest(method: "GET", address: address, uuid: uuid)
        let promise = Promise<Int> { seal in
            Alamofire.request(request).validate(statusCode: 200..<600).responseJSON { response in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET API Results *****")
                    print(json)
                    print("***** GET API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json["count"].intValue)
                    }else {
                        seal.reject(NSError(domain: "センサーに接続できませんでした[-1]", code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "センサーに接続できませんでした[-1]"
                    seal.reject(NSError(domain: err_msg, code: -1))
                }
            }
        }
        return promise
    }
    
    fileprivate func raspiUpdateUUIDRequest(address: String, uuid: String, method: String) -> Promise<String> {
        let indicator = Indicator()
        indicator.start()
        
        let request = GetConnectRaspberryPIRequest(method: method, address: address, uuid: uuid)
        let promise = Promise<String> { seal in
            Alamofire.request(request).validate(statusCode: 200..<600).responseJSON { response in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET API Results *****")
                    print(json)
                    print("***** GET API Results *****")
                    
                    if IsHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill("OK")
                    }else {
                        seal.reject(NSError(domain: "センサーに接続できませんでした[-1]", code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "センサーに接続できませんでした[-1]"
                    seal.reject(NSError(domain: err_msg, code: -1))
                }
            }
        }
        return promise
    }
}



// MARK: - SignUp
extension API {
    func saveUUIDInSensor(isSensorSet: Bool, url: String) -> Promise<String> {
        let uuid = NSUUID().uuidString
        
        if !isSensorSet {
            let promise = Promise<String> { seal in
                seal.fulfill(uuid)
            }
            return promise
        }
        
        return raspiSignUpRequest(address: url, uuid: uuid)
    }
    
    func createUser(params: [String:Any]) -> Promise<JSON> {
        let endPoint = "user"
        return postPutPatchDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .post)
    }
}


// MARK: - Token
extension API {
    func sendToken(token: String) {
        let keychain = Keychain()
        let uuid = (try! keychain.get("uuid"))!
        let params = [
            "token": token,
            "uuid": uuid
        ]
        
        let endPoint = "token"
        let _ = postPutPatchDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put).done { (_) in}
    }
}



// MARK: - OverView
extension API {
    func getOverView() -> Promise<JSON> {
        let keychain = Keychain()
        let id = try! keychain.get("id")!
        let endPoint = "smoke/overview/user/" + id
        return get(url: base + version + endPoint, isShowIndicator: true)
    }
}



// MARK: - ListView
extension API {
    func get24HourSmoke(isShowIndicator: Bool) -> Promise<JSON> {
        let keychain = Keychain()
        let id = try! keychain.get("id")!
        let endPoint = "smoke/24hour/user/" + id
        return get(url: base + version + endPoint, isShowIndicator: isShowIndicator)
    }
    
    func startSmoke() -> Promise<JSON> {
        let keychain = Keychain()
        let uuid = (try! keychain.get("uuid"))!
        let endPoint = "smoke"
        let param = [
            "uuid": uuid,
            "is_sensor": false
            ] as [String : Any]
        
        return postPutPatchDeleteAuth(url: base + version + endPoint, params: param, httpMethod: .post)
    }
    
    func endSmoke() -> Promise<JSON> {
        let keychain = Keychain()
        let smokeID = (try! keychain.getString("smoke_id"))!
        let uuid = (try! keychain.get("uuid"))!
        let endPoint = "smoke/" + smokeID
        let param = [
            "uuid": uuid,
            "minus_sec": 0,
            "is_sensor": false
            ] as [String : Any]
        
        return postPutPatchDeleteAuth(url: base + version + endPoint, params: param, httpMethod: .put)
    }
}



// MARK: - ListEdit
extension API {
    func deleteSmoke(smokeID: Int) -> Promise<JSON> {
        let keychain = Keychain()
        let userID = (try! keychain.getString("id"))!
        let endPoint = "smoke/"+String(smokeID)+"/user/"+userID

        return postPutPatchDeleteAuth(url: base + version + endPoint, params: [:], httpMethod: .delete)
    }
    
    func updateSmoke(start: String, end: String, smokeID: String) -> Promise<JSON> {
        let keychain = Keychain()
        let uuid = (try! keychain.get("uuid"))!
        let endPoint = "smoke/" + smokeID
        let params = [
            "uuid": uuid,
            "started_at": start,
            "ended_at": end
        ]
        return postPutPatchDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .patch)
    }
}



// MARK: - Setting
extension API {
    func getUserData() -> Promise<JSON> {
        let keychain = Keychain()
        let userID = (try! keychain.getString("id"))!
        let endPoint = "user/" + userID
        
        return get(url: base + version + endPoint, isShowIndicator: true)
    }
    
    func updateUserData(params: [String:Any], userID: String) -> Promise<JSON> {
        let endPoint = "user/" + userID
        return postPutPatchDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
    
    func getUUIDCount(address: String) -> Promise<Int> {
        return raspiUUIDCountRequest(address: address, uuid: "")
    }
    
    func updateUUID(address: String, method: String, uuid: String) -> Promise<String> {
        return raspiUpdateUUIDRequest(address: address, uuid: uuid, method: method)
    }
}
