//
//  PrivacyPolicyViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import TinyConstraints
import WebKit

protocol PrivacyPolicyViewInterface: class {
}


class PrivacyPolicyViewController: UIViewController, PrivacyPolicyViewInterface, WKUIDelegate {
    fileprivate var presenter: PrivacyPolicyViewPresenter!
    fileprivate var webView:WKWebView!
    fileprivate let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PrivacyPolicyViewPresenter(view: self)
        initializeWebView()
    }
    
    private func initializeWebView() {
        webView = WKWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.edges(to: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "プライバシーポリシー"
        webView.load(presenter.getURLRequest())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension PrivacyPolicyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        indicator.start()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stop()
    }
}


// MARK: - Presenterから呼び出される関数
extension PrivacyPolicyViewController {
}
