//
//  SmokeDataViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import StatusProvider
import PopupDialog

protocol SmokeDataViewInterface: class {
    func drawView()
    func successStartSmoke()
    func successEndSmoke()
    func showAlert(title: String, msg: String)
}

class SmokeDataViewController: FormViewController, StatusController,  SmokeDataViewInterface {
    fileprivate var presenter: SmokeDataViewPresenter!
    
    var preViewName = StoryBoardID.edit.rawValue
    let refresh_controll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        presenter.setSmokeState()
        
        self.tabBarController?.delegate = self
        self.tableView.refreshControl = self.refresh_controll
        self.refresh_controll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        refresh_controll.beginRefreshing()
        presenter.set24HourSmoke(isShowIndicator: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "編集"
        
        setUpNavigationButton()
        presenter.set24HourSmoke(isShowIndicator: false)
    }
    
    fileprivate func setUpNavigationButton() {
        if presenter.getIsSmoking() {
            let check = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(tapSmokeEndButton))
            self.tabBarController?.navigationItem.setRightBarButton(check, animated: true)
        }else {
            let add = UIBarButtonItem(image: UIImage(named: "icon_add"), style: .plain, target: self, action: #selector(tapSmokeStartButton))
            self.tabBarController?.navigationItem.setRightBarButton(add, animated: true)
        }
    }
    
    @objc private func tapSmokeEndButton() {
        presenter.endSmoke()
    }
    
    @objc private func tapSmokeStartButton() {
        // ended_atがnull(文字数 0)のレコードがある場合は、センサーで計測中の可能性があるので警告アラートを表示
        if presenter.getEndNullCount() == 0 {
            presenter.startSmoke()
        }else {
            let popup = PopupDialog(title: "警告", message: "センサーが計測中の可能性があります。ここで新規に記録をした場合、2重で記録される場合があります。\nそれでも記録しますか？")
            let cancel = CancelButton(title: "キャンセル") {}
            let ok = DefaultButton(title: "OK", dismissOnTap: true) {
                self.presenter.startSmoke()
            }
            popup.addButtons([cancel, ok])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    private func initializePresenter() {
        presenter = SmokeDataViewPresenter(view: self)
    }
}


// MARK: - View関係
extension SmokeDataViewController {
    fileprivate func resetViews() {
        self.hideStatus()
        form.removeAll()
    }
    
    fileprivate func createTable() {
        let section = Section("過去24時間の喫煙情報")
        
        for smoke in presenter.getResults() {
            let start = Date.stringFromString(string: smoke["started_at"].stringValue, formatIn: "yyyy-MM-dd HH:mm:ss", formatOut: "yyyy-MM-dd HH:mm")
            
            var end = ""
            if smoke["ended_at"].stringValue == "" {
                end = ""
            }else {
                end = Date.stringFromString(string: smoke["ended_at"].stringValue, formatIn: "yyyy-MM-dd HH:mm:ss", formatOut: "yyyy-MM-dd HH:mm")
            }
            
            let title = "\(start)\n\(end)"
            
            let vc = SmokeDataEditViewController()
            vc.setSmokeInfo(start: smoke["started_at"].stringValue, end: smoke["ended_at"].stringValue, ID: smoke["id"].intValue)
            
            let row = ButtonRow() {
                $0.title = title
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return vc}, onDismiss: {vc in vc.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
                $0.cell.textLabel?.text = title
            }
            
            section.append(row)
        }
        
        form.append(section)
    }
}

// MARK: - Presenterから呼び出される関数一覧
extension SmokeDataViewController {
    func drawView() {
        UIView.setAnimationsEnabled(false)
        resetViews()
        self.refresh_controll.endRefreshing()
        
        if presenter.getResults().count == 0 {
            let status = Status(title: "No Data", description: "喫煙記録がないため、データを表示できません", actionTitle: "Reload", image: nil) {
                self.hideStatus()
                self.presenter.set24HourSmoke(isShowIndicator: true)
            }
            show(status: status)
        }else {
            createTable()
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func successStartSmoke() {
        setUpNavigationButton()
        presenter.set24HourSmoke(isShowIndicator: true)
        ShowStandardAlert(title: "成功", msg: "喫煙開始を記録しました。\n右上のチェックボタンをタップして喫煙終了を記録してください。", vc: self, completion: nil)
    }
    
    func successEndSmoke() {
        setUpNavigationButton()
        presenter.set24HourSmoke(isShowIndicator: true)
        ShowStandardAlert(title: "成功", msg: "喫煙終了を記録しました。", vc: self, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


extension SmokeDataViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryBoardID.edit.rawValue && preViewName == StoryBoardID.edit.rawValue {
            tableView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }
}
