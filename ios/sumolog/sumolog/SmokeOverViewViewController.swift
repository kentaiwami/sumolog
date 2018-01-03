//
//  SmokeOverViewViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/03.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import TinyConstraints

class SmokeOverViewViewController: UIViewController, IndicatorInfoProvider {
    
    var MinLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        MinLabel.removeFromSuperview()
        
        CreateMinLabel(min: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func CreateMinLabel(min: Int) {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 100)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.text = String(min)
        
        MinLabel = label
        
        self.view.addSubview(label)
        
        label.center(in: self.view, offset: CGPoint(x: 0, y: -150))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "OverView")
    }
}
