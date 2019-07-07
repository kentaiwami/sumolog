//
//  SmokeListViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import StatusProvider
import PopupDialog

protocol SmokeListViewInterface: class {
    func drawView()
    func success(title: String, msg: String)
    func showAlert(title: String, msg: String)
}

class SmokeListViewController: FormViewController, StatusController,  SmokeListViewInterface {
    fileprivate var presenter: SmokeListViewPresenter!
    
    var preViewName = StoryBoardID.list.rawValue
    let refresh_controll = UIRefreshControl()
    
    fileprivate let utility = Utility()
    
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
        
        self.tabBarController?.navigationItem.title = "一覧"
        
        setUpNavigationButton()
        presenter.set24HourSmoke(isShowIndicator: true)
    }
    
    fileprivate func setUpNavigationButton() {
        if presenter.getIsSmoking() {
            let check = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(tapSmokeEndButton))
            self.tabBarController?.navigationItem.setRightBarButton(check, animated: true)
        }else {
            let add = UIBarButtonItem(image: UIImage(named: "icon_add"), style: .plain, target: self, action: #selector(tapSmokeStartButton))

            self.tabBarController?.navigationItem.setRightBarButton(add, animated: true)
        }
        let adds = UIBarButtonItem(image: UIImage(named: "icon_adds"), style: .plain, target: self, action: #selector(tapAddsSmokeButton))
        self.tabBarController?.navigationItem.setLeftBarButton(adds, animated: true)
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
            popup.addButtons([ok, cancel])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    @objc private func tapAddsSmokeButton() {
        let nav = UINavigationController()
        let addsFormVC = AddsViewController()
        nav.viewControllers = [addsFormVC]
        present(nav, animated: true, completion: nil)
    }
    
    private func initializePresenter() {
        presenter = SmokeListViewPresenter(view: self)
    }
}


// MARK: - View関係
extension SmokeListViewController {
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
            
            let vc = SmokeListEditViewController()
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
extension SmokeListViewController {
    func drawView() {
        UIView.setAnimationsEnabled(false)
        resetViews()
        self.refresh_controll.endRefreshing()
        
        if presenter.getResults().count == 0 {
            let status = Status(title: "データなし", description: "24時間以内の喫煙記録がないため、データを表示できません", actionTitle: "再読み込み", image: nil) {
                self.hideStatus()
                self.presenter.set24HourSmoke(isShowIndicator: true)
            }
            show(status: status)
        }else {
            createTable()
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func success(title: String, msg: String) {
        setUpNavigationButton()
        presenter.set24HourSmoke(isShowIndicator: true)
        utility.ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        utility.ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


extension SmokeListViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryBoardID.list.rawValue && preViewName == StoryBoardID.list.rawValue {
            tableView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }
}
