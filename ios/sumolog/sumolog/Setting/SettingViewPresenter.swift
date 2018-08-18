//
//  SettingViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

class SettingViewPresenter {
    
    weak var view: SettingViewInterface?
    let model: SettingViewModel
    
    init(view: SettingViewInterface) {
        self.view = view
        self.model = SettingViewModel()
        model.delegate = self
    }
    
    func setUserData() {
        model.setUserData()
    }
    
    func getUserData() -> UserData {
        return model.userData
    }
    
    func isAddressEmpty() -> Bool {
        return model.isAddressEmpty()
    }
    
    func updateUserData() {
        guard let formValues = view?.formValues else {return}
        model.updateUserData(formValues: formValues)
    }
    
    func isSensorConnection() -> Bool {
        return model.isSensorConnection()
    }
    
    func updateSensorConnection() {
        guard let formValues = view?.formValues else {return}
        guard let connection = formValues["connect"] as? Bool else{return}
        model.updateSensorConnection(connection: connection)
    }
}

extension SettingViewPresenter: SettingViewModelDelegate {
    func successGetUserData() {
        view?.createForm()
        model.setUUIDCount()
    }
    
    func successUpdateUUIDCount() {
        view?.updateSwitchCell()
    }
    
    func doneUpdateUserData(title: String, msg: String) {
        view?.doneUpdateUserData(title: title, msg: msg)
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
