//
//  SafariExtensionViewController.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/13/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import SafariServices
import WebKit

class SafariExtensionViewController: SFSafariExtensionViewController {
    static let shared = SafariExtensionViewController()
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        injectGlueCode()
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "dist")
        webView.loadFileURL(url!, allowingReadAccessTo: url!)
        // Bundle.main.resourceURL!.appendingPathComponent("build")
    }
    
    // Configures the WebView with our WebExtension API glue code
    private func injectGlueCode() {
        let url = Bundle.main.url(forResource: "safariglue", withExtension: "js")
        let source = try! String(contentsOf: url!, encoding: .utf8)

        let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        let ucctrl = webView.configuration.userContentController
        ucctrl.add(self, name: "bridge")
        ucctrl.addUserScript(userScript)
    }
    
    // Resize the popover to match the size of document.body
    private func resizeToContent() {
        let js = "let css = window.getComputedStyle(document.body); [ css.width, css.height ]"
        webView.evaluateJavaScript(js) {
            result, error in
            
            guard let result = result as? [String], error == nil else {
                NSLog("Failed to get preferred content size: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            let width = (result[0] as NSString).floatValue
            let height = (result[1] as NSString).floatValue
            self.view.frame.size = NSMakeSize(CGFloat(width), CGFloat(height))
            self.preferredContentSize = self.view.frame.size
        }
    }
}

extension SafariExtensionViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Keep the popover's size constrained to document.body
        resizeToContent()
    }
}

extension SafariExtensionViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        NSLog("Received message \(message.body)")
    }
}
