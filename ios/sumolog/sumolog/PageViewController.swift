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
        let main_color = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.buttonBarItemTitleColor = UIColor.black

        super.viewDidLoad()
        let navBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        let y = (self.navigationController?.navigationBar.frame.origin.y)!
        
        buttonBarView.selectedBar.backgroundColor = main_color
        buttonBarView.backgroundColor = UIColor.clear
        buttonBarView.frame = CGRect(x: 0, y: navBarHeight+y, width: buttonBarView.frame.width, height: buttonBarView.frame.height)
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [SmokeOverViewViewController(), SmokeDetailViewController()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
