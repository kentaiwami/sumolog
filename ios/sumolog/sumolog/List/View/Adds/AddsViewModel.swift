//
//  AddsViewModel.swift
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
    func successAdds()
    func faildAPI(title: String, msg: String)
}

class AddsViewModel {
    weak var delegate: AddsFormViewModelDelegate?
    private let api = API()
    private let keychain = Keychain()
    
    func isVaildValue(formValues: [String:Any?]) -> Bool {
        let start = formValues["start"] as! Date
        let end = formValues["end"] as! Date
        let diffMin = Int(ceil(end.timeIntervalSince(start) / 60))
        let sumSmokeTimeMin = (formValues["time"] as! Int) * (formValues["number"] as! Int)
        let sumIntervalTimeMin = (formValues["number"] as! Int) - 1
        
        if diffMin > (sumSmokeTimeMin+sumIntervalTimeMin) {
            return true
        }else {
            return false
        }
    }
    
    func adds(formValues: [String:Any?]) {
        let dateFormatter = Utility().getDateFormatter(format: "yyyy-MM-dd HH:mm:ss")
        let params = [
            "start_point": dateFormatter.string(from: formValues["start"] as! Date),
            "end_point": dateFormatter.string(from: formValues["end"] as! Date),
            "uuid": (try! keychain.get("uuid"))!,
            "smoke_time": formValues["time"] as! Int,
            "smoke_count": formValues["number"] as! Int
            ] as [String : Any]
        
        api.addSmokes(params: params).done { (json) in
            self.delegate?.successAdds()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "エラー(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
