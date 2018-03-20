//
//  ViewController.swift
//  trusty
//
//  Created by Sergey Mihalenko on 15.02.18.
//  Copyright © 2018 trustyfund. All rights reserved.
//

import UIKit
import WebKit
import UserNotifications
import Firebase
import JavaScriptCore

class ViewController: UIViewController {
    
    var webView: WKWebView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func newToken(notification: NSNotification) {
        setToken(token: (notification.object as? String) ?? "")
    }
    func setToken(token: String) {
        webView.evaluateJavaScript("if(_GlobalIOSCallback) _GlobalIOSCallback('\(token)');",
            completionHandler: { _, _ in })
    }
    
    override func loadView() {
        super.loadView()
        
        let controller = WKUserContentController()
        
        //scale config
        let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(viewportScript)
        
        //disable selection
        let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
        let disableSelectionScript = WKUserScript(source: disableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(disableSelectionScript)
        //disable callouts
        
        let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
        let disableCalloutScript = WKUserScript(source: disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(disableCalloutScript)
        
        let redirectConsoleScriptString = "document.addEventListener('message', function(e){ window.webkit.messageHandlers.iosListener.postMessage(e.data); })"
        let redirectConsoleScript = WKUserScript(source: redirectConsoleScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(redirectConsoleScript)
        
        let subscribeFunctionScriptString = "function subscribeFCMToken(callback) { " +
        "_GlobalIOSCallback = callback; " +
        "window.webkit.messageHandlers.iosListener.postMessage('subscribeFCM'); " +
        "};"
        let subscribeFunctionScript = WKUserScript(source: subscribeFunctionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(subscribeFunctionScript)
        
        /*let testFNScriptString = "function testFn() { return 'testString'; }"
        let testFNScript = WKUserScript(source: testFNScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(testFNScript)*/
        
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        config.userContentController.add(self, name: "iosListener")
        config.preferences = preferences
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

        NotificationCenter.default.addObserver(self, selector: #selector(newToken), name: NSNotification.Name("newToken"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WKWebsiteDataStore.default().removeData(
            ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
            modifiedSince: Date(timeIntervalSince1970: 0),
            completionHandler: {});
        
        let myURL = URL(string: "http://192.168.10.36:8080/index.html")
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
    /*func printHTML() {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    print(html)
        })
    }*/
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("failed")
        print(error)
    }
}

extension ViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        switch (message.body as! String) {
        case "subscribeFCM":
            if let token = Messaging.messaging().fcmToken {
                setToken(token: token)
            }
            (UIApplication.shared.delegate as! AppDelegate).registerForNotifications()
            
            break
        default:
            print("message: \(message.body)")
        }
    }
}
