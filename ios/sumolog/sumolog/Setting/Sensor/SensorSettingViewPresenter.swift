//
//  SensorSettingViewPresenter.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation

class SensorSettingViewPresenter {
    
    weak var view: SensorSettingViewInterface?
    let model: SensorSettingViewModel
    
    init(view: SensorSettingViewInterface) {
        self.view = view
        self.model = SensorSettingViewModel()
        model.delegate = self
    }
    
    func setSensorData() {
        model.setSensorData()
    }
    
    func getSensorData() -> SensorData {
        return model.sensorData
    }
    
    func isAddressEmpty() -> Bool {
        return model.isAddressEmpty()
    }
    
    func updateSensorData() {
        guard let formValues = view?.formValues else {return}
        model.updateSensorData(formValues: formValues)
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

extension SensorSettingViewPresenter: SensorSettingViewModelDelegate {
    func successGetSensorData() {
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
