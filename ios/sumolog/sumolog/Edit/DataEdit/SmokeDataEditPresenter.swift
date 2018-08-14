//
//  SmokeDataEditViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import SwiftyJSON

class SmokeDataEditViewPresenter {
    
    weak var view: SmokeDataEditViewInterface?
    let model: SmokeDataEditViewModel
    
    init(view: SmokeDataEditViewInterface) {
        self.view = view
        self.model = SmokeDataEditViewModel()
        model.delegate = self
    }
    
    func setSmokeInfo(start: String, end: String, ID: Int) {
        model.setSmokeInfo(start: start, end: end, ID: ID)
    }
    
    func getSmokeTime() -> (start: String, end: String) {
        return (model.startedAt, model.endedAt)
    }
    
    func isEndedAtEmpty() -> Bool {
        return model.isEndedAtEmpty()
    }
    
    func deleteSmoke() {
        model.deleteSmoke()
    }
    
    func updateSmoke(isReset: Bool) {
        guard let start = view?.start else {return}
        guard let end = view?.end else {return}
        model.updateSmoke(start: start, end: end, isReset: isReset)
    }
}

extension SmokeDataEditViewPresenter: SmokeDataEditViewModelDelegate {
    func successUpdateOrDeleteSmoke() {
        view?.popView()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
