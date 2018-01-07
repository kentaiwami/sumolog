//
//  SmokeOverViewViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/03.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import TinyConstraints
import Alamofire
import KeychainAccess
import SwiftyJSON
import ScrollableGraphView

class SmokeOverViewViewController: UIViewController, ScrollableGraphViewDataSource {
    var data = SmokeOverViewData()
    let indicator = Indicator()
    var id = ""
    
    var latestLabel = UILabel()
    var aveLabel = UILabel()
    var smoke_countLabel = UILabel()
    var descriptionLabel: [UILabel] = []
    var borderView: [UIView] = []
    var graphView = ScrollableGraphView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Data"
        CallGetOverViewAPI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keychain = Keychain()
        id = (try! keychain.getString("id"))!
    }
    
    func CallGetOverViewAPI() {
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + API.overview.rawValue + API.user.rawValue + id
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
        latestLabel.removeFromSuperview()
        aveLabel.removeFromSuperview()
        
        for label in descriptionLabel {
            label.removeFromSuperview()
        }
        descriptionLabel.removeAll()
        
        for view in borderView {
            view.removeFromSuperview()
        }
        borderView.removeAll()
        smoke_countLabel.removeFromSuperview()
//        graphView.removeFromSuperview()
        
        CreateLatestLabel()
        CreateDescriptionLabel(str: "Latest", target: latestLabel)
        CreateAveLabel()
        CreateDescriptionLabel(str: "Ave", target: aveLabel)
        CreateBorderView(target: descriptionLabel.last!)
        
        CreateSumSmokesCountLabel()
        CreateDescriptionLabel(str: "24hour smoked", target: smoke_countLabel)
        CreateBorderView(target: descriptionLabel.last!)
        
//        CreateGraphView()
//
//        GenerateAlert()
    }
    
    func CreateLatestLabel() {
        var h = 0
        var m = 0
        var str = ""
        let min = data.GetMin()
        if min >= 60 {
            h = min / 60
            m = min % 60
            
            if m == 0 {
                str = String(h)+"h"
            }else {
                str = String(h)+"h"+String(m)+"m"
            }
        }else {
            m = min
            str = String(m)+"m"
        }
        
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.attributedText = GetAttrString(str: str)
        
        latestLabel = label
        
        self.view.addSubview(label)
        
        label.topToBottom(of: (self.navigationController?.navigationBar)!, offset: 25)
        label.centerX(to: self.view, offset: -100)
    }
    
    func CreateAveLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.attributedText = GetAttrString(str: String(data.GetAve()) + "m")
        
        aveLabel = label
        
        self.view.addSubview(label)
        
        label.topToBottom(of: (self.navigationController?.navigationBar)!, offset: 25)
        label.centerX(to: self.view, offset: 100)
    }
    
    func GetAttrString(str: String) -> NSAttributedString {
        let attr_str = NSMutableAttributedString(string: str)
        
        let chars:[Character] = ["h", "m", "n", "u"]
        
        for char in chars {
            let char_index = str.index(of: char)
            
            if let char_index = char_index {
                let position = str.distance(from: str.startIndex, to: char_index).advanced(by: 0)
                attr_str.addAttribute(NSFontAttributeName, value: UIFont(name: Font.HiraginoW3.rawValue, size: 30), range: NSRange(location: position, length: 1))
            }
        }
        
        return attr_str
    }
    
    func CreateDescriptionLabel(str: String, target: UILabel) {
        let attr_str = NSMutableAttributedString(string: str)
        attr_str.addAttribute(NSFontAttributeName, value: UIFont(name: Font.HiraginoW3.rawValue, size: 15), range: NSRange(location: 0, length: attr_str.length))
        
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 0.5)
        label.attributedText = attr_str
        
        self.view.addSubview(label)
        
        descriptionLabel.append(label)
        
        label.topToBottom(of: target)
        label.centerX(to: target)
    }
    
    func CreateBorderView(target: UILabel) {
        let view = UIView()
        view.backgroundColor = UIColor.hex(Color.gray.rawValue, alpha: 0.5)
        
        self.view.addSubview(view)
        
        borderView.append(view)
        
        view.topToBottom(of: target)
        view.height(2)
        view.width(self.view.frame.width)
    }
    
    func CreateSumSmokesCountLabel() {
        // 目標本数を超過していたら赤文字
        var textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        if data.GetOver() > 0 {
            textColor = UIColor.red
        }

        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = textColor
        label.attributedText = GetAttrString(str: String(data.GetCount()) + "num")

        smoke_countLabel = label

        self.view.addSubview(label)

        label.topToBottom(of: borderView.last!, offset: 0)
        label.centerX(to: self.view)
    }
    
    
//    func CreateGraphView() {
//
//        let frame = CGRect.zero
//        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
//        let barPlot = BarPlot(identifier: "bar")
//
//        barPlot.barWidth = 5
//        barPlot.barLineWidth = 1
//        barPlot.barLineColor = UIColor.clear
//        barPlot.barColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
//        barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
//        barPlot.animationDuration = 1.0
//
//        let referenceLines = ReferenceLines()
//        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
//        referenceLines.referenceLineColor = UIColor.hex(Color.gray.rawValue, alpha: 0.1)
//        referenceLines.referenceLineLabelColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
//        referenceLines.dataPointLabelColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
//
//
//        graphView.rangeMin = 0
//        graphView.rangeMax = CalcMaxRange()
//        graphView.backgroundFillColor = UIColor.white
//        graphView.shouldAnimateOnStartup = true
//        graphView.addPlot(plot: barPlot)
//        graphView.addReferenceLines(referenceLines: referenceLines)
//        graphView.direction = .rightToLeft
//        graphView.dataPointSpacing = 30
//
//        self.graphView = graphView
//
//        self.view.addSubview(graphView)
//
//        graphView.width(to: self.view)
//        graphView.leading(to: self.view)
//        graphView.trailing(to: self.view)
//        graphView.topToBottom(of: smokeImageView, offset: 20)
//        graphView.bottom(to: self.view, offset: -80)
//    }
    
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
    
    func CalcMaxRange() -> Double {
        let data_split = 4
        
        // 最大値を求める
        var max = 0
        for obj in data.GetHour() {
            let key = obj.keys.first!
            
            if max < obj[key]! {
                max = obj[key]!
            }
        }
        
        // MaxRangeを求める
        if max == 0 {
            return Double(data_split)
        }
        
        if max % data_split == 0 {
            return Double(max)
        }else {
            return Double((max/data_split+1) * data_split)
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
}
