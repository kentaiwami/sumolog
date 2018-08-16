//
//  AddsFormViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol AddsFormViewModelDelegate: class {
    func faildAPI(title: String, msg: String)
}

class AddsFormViewModel {
    weak var delegate: AddsFormViewModelDelegate?
    private let api = API()
    private let keychain = Keychain()
    
    func adds(formValues: [String:Any?]) {
        print(formValues)
    }
}
