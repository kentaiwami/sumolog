//
//  SmokeDataViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import SwiftyJSON

class SmokeDataViewPresenter {
    
    weak var view: SmokeDataViewInterface?
    let model: SmokeDataViewModel
    
    init(view: SmokeDataViewInterface) {
        self.view = view
        self.model = SmokeDataViewModel()
        model.delegate = self
    }
    
    func setSmokeState() {
        model.setSmokeState()
    }
    
    func getIsSmoking() -> Bool {
        return model.getIsSmoking()
    }
    
    func getResults() -> [JSON] {
        return model.getResults()
    }
    
    func set24HourSmoke(isShowIndicator: Bool) {
        model.setResults(isShowIndicator: isShowIndicator)
    }
    
    func getEndNullCount() -> Int {
        return model.getEndNullCount()
    }
    
    func startSmoke() {
        model.startSmoke()
    }
    
    func endSmoke() {
        model.endSmoke()
    }
}

extension SmokeDataViewPresenter: SmokeDataViewModelDelegate {
    func drawView() {
        view?.drawView()
    }
    
    func successStartSmoke() {
        view?.successStartSmoke()
    }
    
    func successEndSmoke() {
        view?.successEndSmoke()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
