//
//  UserSettingViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol UserSettingViewModelDelegate: class {
    func successGetUserData()
    func doneUpdateUserData(title: String, msg: String)
    func faildAPI(title: String, msg: String)
}

class UserSettingViewModel {
    weak var delegate: UserSettingViewModelDelegate?
    private let api = API()
    private let keychain = Keychain()
    private(set) var userData = UserData()
    
    func setUserData() {
        let userID = (try! keychain.getString("id"))!

        api.getUserData(userID: userID).done { (json) in
            self.userData.setAll(json: json)
            self.delegate?.successGetUserData()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateUserData(formValues: [String:Any?]) {
        let uuid = (try! keychain.get("uuid"))!
        let userID = try! keychain.get("id")!
        
        let params = [
            "uuid": uuid,
            "payday": formValues["payday"] as! Int,
            "price": formValues["price"] as! Int,
            "target_number": formValues["target_number"] as! Int
            ] as [String : Any]
        
        api.updateUserData(params: params, userID: userID).done { (json) in
            self.userData.setAll(json: json)
            self.delegate?.doneUpdateUserData(title: "成功", msg: "情報を更新しました")
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.doneUpdateUserData(title: title, msg: tmp_err.domain)
        }
    }
}
