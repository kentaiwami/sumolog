//
//  SmokeOverViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

class SmokeOverViewPresenter {
    
    weak var view: SmokeOverViewInterface?
    let model: SmokeOverViewModel
    
    init(view: SmokeOverViewInterface) {
        self.view = view
        self.model = SmokeOverViewModel()
        model.delegate = self
    }
    
    func getMaxRange() -> Double {
        return model.calcMaxRange()
    }
    
    func getLatestLabelText(min: Int) -> String {
        return model.getLatestLabelText(min: min)
    }
    
    func setOverViewData() {
        model.setOverViewData()
    }
    
    func getOverViewData() -> SmokeOverViewData {
        return model.getOverViewData()
    }
    
    func isViewHidden() -> (graphView: Bool, noDataView: Bool) {
        return model.isViewHidden()
    }
}

extension SmokeOverViewPresenter: SmokeOverViewModelDelegate {
    func showNoData() {
        view?.showNoData()
    }
    
    func initViews() {
        view?.initViews()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
