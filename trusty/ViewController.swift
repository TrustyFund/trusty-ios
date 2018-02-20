//
//  ViewController.swift
//  trusty
//
//  Created by Sergey Mihalenko on 15.02.18.
//  Copyright © 2018 trustyfund. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        super.loadView()
        
        //scale config
        let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
        
        //disable selection and callouts
        let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
        let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
        
        let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let disableSelectionScript = WKUserScript(source: disableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let disableCalloutScript = WKUserScript(source: disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        
        let controller = WKUserContentController()
        
        controller.addUserScript(viewportScript)
        controller.addUserScript(disableSelectionScript)
        controller.addUserScript(disableCalloutScript)
        
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        webView = WKWebView(frame: .zero, configuration: config)
        
        webView.scrollView.bounces = false
        webView.allowsBackForwardNavigationGestures = false
        webView.contentMode = .scaleToFill

        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        //webView.backgroundColor = .black
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: "http://beta.trusty.fund")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        setNeedsStatusBarAppearanceUpdate()
    }
    

}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("1")
        print(error)
    }
}
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("nav finish")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("failed")
        print(error)
    }
}

