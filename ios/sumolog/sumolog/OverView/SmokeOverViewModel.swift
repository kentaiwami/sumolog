//
//  SmokeOverViewModel.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import KeychainAccess

protocol SmokeOverViewModelDelegate: class {
    func initViews()
    func showNoData()
    func faildAPI(title: String, msg: String)
}

class SmokeOverViewModel {
    weak var delegate: SmokeOverViewModelDelegate?
    private let api = API()
    
    private(set) var data = SmokeOverViewData()
    private(set) var id = ""
    
    func calcMaxRange() -> Double {
        let data_split = 4
        
        // 最大値を求める
        var max = 0
        for obj in data.getHour() {
            let key = obj.keys.first!
            
            if max < obj[key]! {
                max = obj[key]!
            }
        }
        
        // MaxRangeを求める
        if max == 0 {
            return Double(data_split)
        }
        
        if max % data_split == 0 {
            return Double(max)
        }else {
            return Double((max/data_split+1) * data_split)
        }
    }
    
    func getLatestLabelText(min: Int) -> String {
        var h = 0
        var m = 0
        var str = ""
        
        if min >= 60 {
            h = min / 60
            m = min % 60
            
            if m == 0 {
                str = String(h)+"h"
            }else {
                str = String(h)+"h"+String(m)+"m"
            }
        }else {
            m = min
            str = String(m)+"m"
        }
        
        return str
    }
    
    func getOverViewData() -> SmokeOverViewData {
        return data
    }
    
    func setOverViewData() {
        api.getOverView().done { (json) in
            self.data.setAll(json: json)
            self.delegate?.initViews()
        }
        .catch { (err) in
            let tmpErr = err as NSError
            
            if tmpErr.code == 500 {
                self.delegate?.showNoData()
            }else {
                let title = "Error(" + String(tmpErr.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmpErr.domain)
            }
        }
    }
}
