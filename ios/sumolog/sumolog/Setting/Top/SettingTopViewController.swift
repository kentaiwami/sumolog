//
//  SettingTopViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

protocol SettingTopViewInterface: class {}

class SettingTopViewController: FormViewController, SettingTopViewInterface {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "設定"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    private func createForm() {
        UIView.setAnimationsEnabled(false)
        
        let userSettingVC = UserSettingViewController()
        let sensorSettingVC = SensorSettingViewController()
        let privacyPolicyVC = PrivacyPolicyViewController()
        let contactVC = ContactViewController()
        
        form +++ Section(header: "ユーザ", footer: "")
            <<< ButtonRow() {
                $0.title = "ユーザ情報"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return userSettingVC}, onDismiss: {userSettingVC in userSettingVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = "センサー"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return sensorSettingVC}, onDismiss: {sensorSettingVC in sensorSettingVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
        form +++ Section(header: "その他", footer: "")
            <<< ButtonRow() {
                $0.title = "プライバシーポリシー"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return privacyPolicyVC}, onDismiss: {privacyPolicyVC in privacyPolicyVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = "お問い合わせ"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return contactVC}, onDismiss: {contactVC in contactVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
        UIView.setAnimationsEnabled(true)
    }
}
