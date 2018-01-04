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
import Alamofire
import KeychainAccess
import SwiftyJSON

class SmokeOverViewViewController: UIViewController, IndicatorInfoProvider {
    var data = SmokeOverViewData()
    let indicator = Indicator()
    var id = ""
    
    var latest_minLabel = UILabel()
    var minLabel = UILabel()
    var smoke_countLabel = UILabel()
    var smokeImageView = UIImageView()
    
    override func viewWillAppear(_ animated: Bool) {
        CallGetOverViewAPI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keychain = Keychain()
        id = (try! keychain.getString("id"))!
    }
    
    func CallGetOverViewAPI() {
        let urlString = API.base.rawValue + API.smoke.rawValue + API.overview.rawValue + API.user.rawValue + id
        indicator.showIndicator(view: self.view)
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            self.indicator.stopIndicator()
            
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("Smoke Overview results: ", json.count)
            print(json)
            
            self.data.SetAll(json: json)
            
            self.DrawViews()
        }
    }
    
    func DrawViews() {
        latest_minLabel.removeFromSuperview()
        minLabel.removeFromSuperview()
        smoke_countLabel.removeFromSuperview()
        smokeImageView.removeFromSuperview()
        
        CreateLatestMinLabel(min: data.GetMin())
        CreateMinLabel()
        CreateSumSmokesCountLabel()
        CreateSmokeImageView()
    }
    
    func CreateLatestMinLabel(min: Int) {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 100)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.text = String(min)
        
        latest_minLabel = label
        
        self.view.addSubview(label)
        
        label.center(in: self.view, offset: CGPoint(x: 0, y: -150))
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
    
    func CreateSumSmokesCountLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 30)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.text = "25"
        
        smoke_countLabel = label
        
        self.view.addSubview(label)
        
        label.trailing(to: self.view, offset: -10)
        label.topToBottom(of: minLabel, offset: 30)
    }
    
    func CreateSmokeImageView() {
        let size = 30 as CGFloat
        let imageView = UIImageView(image: UIImage(named: "icon_smoke"))
        imageView.frame = CGRect.zero
        
        smokeImageView = imageView
        
        self.view.addSubview(imageView)
        
        imageView.trailingToLeading(of: smoke_countLabel)
        imageView.centerY(to: smoke_countLabel)
        imageView.width(size)
        imageView.height(size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "OverView")
    }
}
