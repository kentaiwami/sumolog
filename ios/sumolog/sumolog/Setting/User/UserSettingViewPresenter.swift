//
//  UserSettingViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

class UserSettingViewPresenter {
    
    weak var view: UserSettingViewInterface?
    let model: UserSettingViewModel
    
    init(view: UserSettingViewInterface) {
        self.view = view
        self.model = UserSettingViewModel()
        model.delegate = self
    }
    
    func setUserData() {
        model.setUserData()
    }
    
    func getUserData() -> UserData {
        return model.userData
    }
    
    func updateUserData() {
        guard let formValues = view?.formValues else {return}
        model.updateUserData(formValues: formValues)
    }
}

extension UserSettingViewPresenter: UserSettingViewModelDelegate {
    func successGetUserData() {
        view?.createForm()
    }
    
    func doneUpdateUserData(title: String, msg: String) {
        view?.doneUpdateUserData(title: title, msg: msg)
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
