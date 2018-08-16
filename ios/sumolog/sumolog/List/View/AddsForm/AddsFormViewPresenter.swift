//
//  AddsFormViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

class AddsFormViewPresenter {
    
    weak var view: AddsFormViewInterface?
    let model: AddsFormViewModel
    
    init(view: AddsFormViewInterface) {
        self.view = view
        self.model = AddsFormViewModel()
        model.delegate = self
    }
    
    func adds() {
        guard let formValues = view?.formValues else {return}
        model.adds(formValues: formValues)
    }
}

extension AddsFormViewPresenter: AddsFormViewModelDelegate {
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
