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
import ScrollableGraphView

class SmokeOverViewViewController: UIViewController, IndicatorInfoProvider, ScrollableGraphViewDataSource {
    var data = SmokeOverViewData()
    let indicator = Indicator()
    var id = ""
    
    var latest_minLabel = UILabel()
    var minLabel = UILabel()
    var smoke_countLabel = UILabel()
    var smokeImageView = UIImageView()
    var graphView = ScrollableGraphView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            
            GetAppDelegate().smokes = self.data.GetCount()
            
            self.DrawViews()
        }
    }
    
    func DrawViews() {
        latest_minLabel.removeFromSuperview()
        minLabel.removeFromSuperview()
        smoke_countLabel.removeFromSuperview()
        smokeImageView.removeFromSuperview()
        graphView.removeFromSuperview()
        
        CreateLatestMinLabel()
        CreateMinLabel()
        CreateSumSmokesCountLabel()
        CreateSmokeImageView()
        CreateGraphView()
        
        GenerateAlert()
    }
    
    func CreateLatestMinLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 100)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.text = String(data.GetMin())
        
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
    
    func CreateSumSmokesCountLabel() {
        // 目標本数を超過していたら赤文字
        var textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        if data.GetOver() > 0 {
            textColor = UIColor.red
        }
        
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 30)
        label.textColor = textColor
        label.text = String(data.GetCount())
        
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
    
    func CreateGraphView() {
        // 最大値を求める
        var max = 0
        for obj in data.GetHour() {
            let key = obj.keys.first!
            
            if max < obj[key]! {
                max = obj[key]!
            }
        }
        
        let frame = CGRect.zero
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        let barPlot = BarPlot(identifier: "bar")
        barPlot.barWidth = 25
        barPlot.barLineWidth = 1
        barPlot.barLineColor = UIColor.clear
        barPlot.barColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        
        barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        barPlot.animationDuration = 1.0
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.hex(Color.gray.rawValue, alpha: 0.1)
        referenceLines.referenceLineLabelColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        referenceLines.dataPointLabelColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        
        
        graphView.rangeMin = 0
        graphView.rangeMax = Double(max)
        graphView.backgroundFillColor = UIColor.white
        graphView.shouldAnimateOnStartup = true
        graphView.addPlot(plot: barPlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        
        self.graphView = graphView
        
        self.view.addSubview(graphView)
        
        graphView.width(to: self.view)
        graphView.leading(to: self.view)
        graphView.trailing(to: self.view)
        graphView.topToBottom(of: smokeImageView, offset: 20)
        graphView.bottom(to: self.view, offset: -80)
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        let hour = data.GetHour()
        
        switch(plot.identifier) {
        case "bar":
            let key = hour[pointIndex].keys.first!
            let value = hour[pointIndex][key]
            
            return Double(value!)
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return data.GetHour()[pointIndex].keys.first! + "時"
    }
    
    func numberOfPoints() -> Int {
        return data.GetHour().count
    }
    
    func GenerateAlert() {
        if data.GetOver() > 0 {
            self.present(GetStandardAlert(title: "", message: "目標本数を"+String(data.GetOver())+"本超過しています", b_title: "OK"), animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "OverView")
    }
}
