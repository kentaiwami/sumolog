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
    
    var latest_minLabel = UILabel()
    var minLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        latest_minLabel.removeFromSuperview()
        minLabel.removeFromSuperview()
        
        CreateLatestMinLabel(min: 50)
        CreateMinLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func CreateLatestMinLabel(min: Int) {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 100)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.text = String(min)
        
        latest_minLabel = label
        
        self.view.addSubview(label)
        
        label.center(in: self.view, offset: CGPoint(x: 0, y: -100))
    }
    
    func CreateMinLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW6.rawValue, size: 30)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.text = "min"
        
        minLabel = label
        
        self.view.addSubview(label)
        
        label.topToBottom(of: latest_minLabel, offset: -10)
        label.leadingToTrailing(of: latest_minLabel, offset: -20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "OverView")
    }
}
