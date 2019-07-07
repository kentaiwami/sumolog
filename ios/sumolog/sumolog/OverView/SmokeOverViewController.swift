//
//  SmokeOverViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import ScrollableGraphView
import StatusProvider
import UserNotifications
import TinyConstraints

protocol SmokeOverViewInterface: class {
    func initViews()
    func showNoData()
    func showAlert(title: String, msg: String)
}

class SmokeOverViewController: UIViewController, StatusController,  SmokeOverViewInterface {
    fileprivate var presenter: SmokeOverViewPresenter!
    var latestLabel = UILabel()
    var aveLabel = UILabel()
    var smoke_countLabel = UILabel()
    var usedLabel = UILabel()
    var descriptionLabel: [UILabel] = []
    var borderView: [UIView] = []
    var graphView = ScrollableGraphView()
    var noDataView = UIView()
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializePresenter()
        
        UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]) {(accepted, error) in
            if accepted {
                print("Notification access accepted !")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else{
                print("Notification access denied.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "概要"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        removeViews()
        presenter.setOverViewData()
    }
    
    private func initializePresenter() {
        presenter = SmokeOverViewPresenter(view: self)
    }
    
    fileprivate func createViews() {
        // 直近の喫煙時間、平均時間
        createLatestLabel()
        createDescriptionLabel(str: "直近の喫煙", target: latestLabel)
        createAveLabel()
        createDescriptionLabel(str: "1本あたりの喫煙時間", target: aveLabel)
        createBorderView(target: descriptionLabel.last!)
        
        // 24時間の喫煙本数
        createSumSmokesCountLabel()
        createDescriptionLabel(str: "過去24時間の喫煙本数", target: smoke_countLabel)
        createBorderView(target: descriptionLabel.last!)
        
        // 使用済みの金額
        createUsedLabel()
        createDescriptionLabel(str: "給与日から使用した金額", target: usedLabel)
        createBorderView(target: descriptionLabel.last!)
        
        // グラフ
        createGraphView()
        
        let tmpOver = presenter.getOverViewData().getOver()
        if tmpOver > 0 {
            utility.showStandardAlert(title: "", msg: "目標本数を"+String(tmpOver)+"本超過しています", vc: self, completion: nil)
        }
    }
    
    fileprivate func removeViews() {
        self.hideStatus()
        
        latestLabel.removeFromSuperview()
        aveLabel.removeFromSuperview()
        smoke_countLabel.removeFromSuperview()
        usedLabel.removeFromSuperview()
        graphView.removeFromSuperview()
        noDataView.removeFromSuperview()
        
        for label in descriptionLabel {
            label.removeFromSuperview()
        }
        
        for view in borderView {
            view.removeFromSuperview()
        }
        
        borderView.removeAll()
        descriptionLabel.removeAll()
    }

}

// MARK: - Presenterから呼び出される関数一覧
extension SmokeOverViewController {
    func initViews() {
        createViews()
    }
    
    func showNoData() {
        let status = Status(title: "データなし", description: "喫煙記録がないため、データを表示できません", actionTitle: "再読み込み", image: nil) {
            self.hideStatus()
            self.removeViews()
            self.presenter.setOverViewData()
        }
        
        self.show(status: status)
    }
    
    func showAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}



// MARK: - 補助関数
extension SmokeOverViewController {
    fileprivate func getAttrString(str: String) -> NSAttributedString {
        let attr_str = NSMutableAttributedString(string: str)
        
        let chars:[Character] = ["h", "m", "本"]
        
        for char in chars {
            let char_index = str.firstIndex(of: char)
            
            if let char_index = char_index {
                let position = str.distance(from: str.startIndex, to: char_index).advanced(by: 0)
                attr_str.addAttribute(NSAttributedString.Key.font, value: UIFont(name: Font.HiraginoW3.rawValue, size: 30)!, range: NSRange(location: position, length: 1))
            }
        }
        
        return attr_str
    }
    
    fileprivate func getNumber(num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        let result = formatter.string(from: NSNumber(value: num))
        
        return result!
    }
}

// MARK: - Labelなどの要素の生成関連
extension SmokeOverViewController {
    fileprivate func createLatestLabel() {
        let offset: CGFloat = 25
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.attributedText = getAttrString(str: presenter.getLatestLabelText(min: presenter.getOverViewData().getMin()))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        latestLabel = label
        
        self.view.addSubview(label)
        
        label.topToBottom(of: (self.navigationController?.navigationBar)!, offset: offset)
        label.left(to: self.view, offset: offset)
        label.width(self.view.frame.width/2 - offset)
    }
    
    fileprivate func createAveLabel() {
        let offset: CGFloat = 25
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.attributedText = getAttrString(str: String(presenter.getOverViewData().getAve()) + "m")
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        aveLabel = label
        
        self.view.addSubview(label)
        
        label.topToBottom(of: (self.navigationController?.navigationBar)!, offset: offset)
        label.right(to: self.view, offset: -offset)
        label.width(self.view.frame.width/2 - offset)
    }
    
    fileprivate func createDescriptionLabel(str: String, target: UILabel) {
        let attr_str = NSMutableAttributedString(string: str)
        attr_str.addAttribute(NSAttributedString.Key.font, value: UIFont(name: Font.HiraginoW3.rawValue, size: 15)!, range: NSRange(location: 0, length: attr_str.length))
        
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 0.5)
        label.attributedText = attr_str
        
        self.view.addSubview(label)
        
        descriptionLabel.append(label)
        
        label.topToBottom(of: target, offset: 5)
        label.centerX(to: target)
    }
    
    fileprivate func createBorderView(target: UILabel) {
        let view = UIView()
        view.backgroundColor = UIColor.hex(Color.gray.rawValue, alpha: 0.25)
        
        self.view.addSubview(view)
        
        borderView.append(view)
        
        view.topToBottom(of: target, offset: 25)
        view.height(1)
        view.width(self.view.frame.width)
    }
    
    fileprivate func createSumSmokesCountLabel() {
        // 目標本数を超過していたら赤文字
        var textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        if presenter.getOverViewData().getOver() > 0 {
            textColor = UIColor.red
        }
        
        let offset: CGFloat = 25
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.attributedText = getAttrString(str: String(presenter.getOverViewData().getCount()) + "本")
        
        smoke_countLabel = label
        
        self.view.addSubview(label)
        
        label.topToBottom(of: borderView.last!, offset: offset)
        label.centerX(to: self.view)
        label.width(self.view.frame.width - offset*2)
    }
    
    fileprivate func createUsedLabel() {
        let offset: CGFloat = 25
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: Font.HiraginoW3.rawValue, size: 60)
        label.textColor = UIColor.hex(Color.gray.rawValue, alpha: 1.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = "¥" + getNumber(num: presenter.getOverViewData().getUsed())
        
        usedLabel = label
        
        self.view.addSubview(label)
        
        label.topToBottom(of: borderView.last!, offset: offset)
        label.centerX(to: self.view)
        label.width(self.view.frame.width - offset*2)
    }
    
    fileprivate func createGraphView() {
        
        let frame = CGRect.zero
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        let barPlot = BarPlot(identifier: "bar")
        
        barPlot.barWidth = 5
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
        graphView.rangeMax = presenter.getMaxRange()
        graphView.backgroundFillColor = UIColor.white
        graphView.shouldAnimateOnStartup = false
        graphView.addPlot(plot: barPlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.direction = .rightToLeft
        graphView.dataPointSpacing = 30
        
        self.graphView = graphView
        
        self.view.addSubview(graphView)
        graphView.width(to: self.view)
        graphView.left(to: self.view)
        graphView.right(to: self.view)
        graphView.topToBottom(of: borderView.last!, offset: 20)
        graphView.bottom(to: self.view, offset: -80)
    }
}


// MARK: - ScrollableGraphView
extension SmokeOverViewController: ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        let hour = presenter.getOverViewData().getHour()
        
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
        return presenter.getOverViewData().getHour()[pointIndex].keys.first! + "時"
    }
    
    func numberOfPoints() -> Int {
        return presenter.getOverViewData().getHour().count
    }
}
