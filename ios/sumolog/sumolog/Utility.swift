//
//  Utility.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/02.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

class Utility {
    func IsCheckFormValue(form: Form) -> Bool {
        var err_count = 0
        for row in form.allRows {
            if !row.isHidden {
                err_count += row.validate().count
            }
        }
        
        if err_count == 0 {
            return true
        }
        
        return false
    }
    
    func GetConnectRaspberryPIRequest(method: String, address: String, uuid: String) -> URLRequest {
        let tmp_req = ["uuid": uuid]
        var request = URLRequest(url: URL(string: "http://"+address+"/api/v1/user")!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = try! JSONSerialization.data(withJSONObject: tmp_req, options: [])
        
        return request
    }
    
    func GetDateFormatter(format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        
        return dateFormatter
    }
    
    func ShowStandardAlert(title: String, msg: String, vc: UIViewController, completion: (() -> Void)?) {
        let button = DefaultButton(title: "OK", dismissOnTap: true) {}
        let popup = PopupDialog(title: title, message: msg) {
            if let tmpCompletion = completion {
                tmpCompletion()
            }
        }
        popup.transitionStyle = .zoomIn
        popup.addButtons([button])
        vc.present(popup, animated: true, completion: nil)
    }
    
    func IsHTTPStatus(statusCode: Int?) -> Bool {
        let code = String(statusCode!)
        var results:[String] = []
        
        if code.pregMatche(pattern: "2..", matches: &results) {
            return true
        }else {
            return false
        }
    }
    
    fileprivate func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            
            return topViewControlelr
        } else {
            return nil
        }
    }
}


class Indicator {
    let indicator = UIActivityIndicatorView()
    
    func start() {
        if let topViewController: UIViewController = Utility().getTopViewController() {
            indicator.style = .whiteLarge
            indicator.center = topViewController.view.center
            indicator.color = UIColor.gray
            indicator.hidesWhenStopped = true
            topViewController.view.addSubview(indicator)
            topViewController.view.bringSubviewToFront(indicator)
            indicator.startAnimating()
        }
    }
    
    func stop() {
        self.indicator.stopAnimating()
    }
}
