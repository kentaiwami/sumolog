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
    func showRowError(row: BaseRow) {
        let rowIndex = row.indexPath!.row
        while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
            row.section?.remove(at: rowIndex + 1)
        }
        
        if !row.isValid {
            for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                let labelRow = LabelRow() {
                    $0.title = err
                    $0.cell.height = { 30 }
                    $0.cell.contentView.backgroundColor = UIColor.red
                    $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                    $0.cell.textLabel?.textAlignment = .right
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = .white
                    })
                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
            }
        }
    }

    func isCheckFormValue(form: Form) -> Bool {
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
    
    func getConnectRaspberryPIRequest(method: String, address: String, uuid: String) -> URLRequest {
        let tmp_req = ["uuid": uuid]
        var request = URLRequest(url: URL(string: "http://"+address+"/api/v1/user")!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = try! JSONSerialization.data(withJSONObject: tmp_req, options: [])
        
        return request
    }
    
    func getDateFormatter(format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        
        return dateFormatter
    }
    
    func showStandardAlert(title: String, msg: String, vc: UIViewController, completion: (() -> Void)?) {
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
    
    func isHTTPStatus(statusCode: Int?) -> Bool {
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
