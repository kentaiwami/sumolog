//
//  Utility.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/02.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka

func GetStandardAlert(title: String, message: String, b_title: String) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let ok = UIAlertAction(title: b_title, style:UIAlertActionStyle.default)
    
    alertController.addAction(ok)
    
    return alertController
}

func GetAppDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func GetOKCancelAlert(title: String, message: String, ok_action: @escaping () -> Void) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{(action: UIAlertAction!) -> Void in
        print("OK")
        ok_action()
    })
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)

    alertController.addAction(ok)
    alertController.addAction(cancel)
    
    return alertController
}

func GetDeleteCancelAlert(title: String, message: String, delete_action: @escaping () -> Void) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler:{(action: UIAlertAction!) -> Void in
        delete_action()
    })
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
    
    alertController.addAction(delete)
    alertController.addAction(cancel)
    
    return alertController
}

func GenerateDate() -> Array<Int> {
    var date_array:[Int] = []
    for i in 1...31 {
        date_array.append(i)
    }
    
    return date_array
}

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
    let urlString = "http://" + address + "/api/v1/user"
    let tmp_req = ["uuid": uuid]
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 10
    request.httpBody = try! JSONSerialization.data(withJSONObject: tmp_req, options: [])
    
    return request
}

class Indicator {
    let indicator = UIActivityIndicatorView()
    
    func showIndicator(view: UIView) {
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = view.center
        indicator.color = UIColor.gray
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        view.bringSubview(toFront: indicator)
        indicator.startAnimating()
    }
    
    func stopIndicator() {
        self.indicator.stopAnimating()
    }
}
