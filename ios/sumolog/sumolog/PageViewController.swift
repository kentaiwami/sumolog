//
//  PageViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/03.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class PageViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [SmokeOverViewViewController(), SmokeDetailViewController()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
