//
//  SmokeDetailViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/03.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Eureka
import Alamofire
import SwiftyJSON
import TinyConstraints
import KeychainAccess

class SmokeDetailViewController: UIViewController, IndicatorInfoProvider {

    var msgLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DrawViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func DrawViews() {
        msgLabel.removeFromSuperview()
        
        CreateMsgLabel()
    }
    
    func CreateMsgLabel() {
        let label = UILabel()
        label.text = "1本あたり"
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 15)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        
        msgLabel = label
        
        self.view.addSubview(label)
        
        label.centerX(to: self.view)
        label.centerY(to: self.view, offset: -230)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Detail")
    }
}
