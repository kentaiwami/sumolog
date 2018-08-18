//
//  AddsViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

class AddsViewPresenter {
    
    weak var view: AddsViewInterface?
    let model: AddsViewModel
    
    init(view: AddsViewInterface) {
        self.view = view
        self.model = AddsViewModel()
        model.delegate = self
    }
    
    func isVaildValue() -> Bool {
        guard let formValues = view?.formValues else {return false}
        return model.isVaildValue(formValues: formValues)
    }
    
    func adds() {
        guard let formValues = view?.formValues else {return}
        model.adds(formValues: formValues)
    }
}

extension AddsViewPresenter: AddsFormViewModelDelegate {
    func successAdds() {
        view?.successAdds()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
