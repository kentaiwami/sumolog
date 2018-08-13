//
//  AppDelegate.swift
//  sumolog
//
//  Created by 岩見建汰 on 2017/10/25.
//  Copyright © 2017年 Kenta. All rights reserved.
//

import UIKit
import KeychainAccess
import Alamofire
import SwiftyJSON
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        resetNotification()
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let reset = GetResetFlag()
        let keychain = Keychain()
        
        if reset {
            try! keychain.removeAll()
        }
        
        if GetInsertDummyDataFlag() {
            let data = GetDummyData()
            try! keychain.set(data.uuid, key: "uuid")
            try! keychain.set(data.id, key: "id")
            try! keychain.set(String(data.is_smoking), key: "is_smoking")
            try! keychain.set(data.smoke_id, key: "smoke_id")
        }
        
        let key = try! keychain.getString("uuid")
        
        if key == nil {
            let signupVC = SignUpViewController()
            let nav = UINavigationController()
            nav.viewControllers = [signupVC]
            self.window!.rootViewController = nav
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var deviceToken = String(format: "%@", deviceToken as CVarArg) as String
        print("deviceToken = \(deviceToken)")
        
        let characterSet: CharacterSet = CharacterSet.init(charactersIn: "<>")
        deviceToken = deviceToken.trimmingCharacters(in: characterSet)
        deviceToken = deviceToken.replacingOccurrences(of: " ", with: "")
        
        SendToken(token: deviceToken)
        
        print("deviceToken = \(deviceToken)")
    }
    
    func SendToken(token: String){
        let keychain = Keychain()
        let uuid = (try! keychain.get("uuid"))!
        
        let urlString = APIOld.base.rawValue + APIOld.v1.rawValue + APIOld.token.rawValue
        let params = [
            "token": token,
            "uuid": uuid
        ]
        
        Alamofire.request(urlString, method: .put, parameters: params, encoding: JSONEncoding(options: [])).responseJSON { (response) in
            guard let obj = response.result.value else {return}
            let json = JSON(obj)

            print("***** API results *****")
            print(json)
            print("***** API results *****")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        resetNotification()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        resetNotification()
    }
    
    func resetNotification() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert, .badge])
    }
}

