//
//  SignUpViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

class SignUpViewPresenter {
    
    weak var view: SignUpViewInterface?
    let model: SignUpViewModel
    
    init(view: SignUpViewInterface) {
        self.view = view
        self.model = SignUpViewModel()
        model.delegate = self
    }
    
    func signUp() {
        guard let formValues = view?.formValues else {return}
        model.signUp(formValues: formValues)
    }
}

extension SignUpViewPresenter: SignUpViewModelDelegate {
    func successSignUp() {
        view?.navigateTopView()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
