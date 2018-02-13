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
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "build")
        webView.loadFileURL(url!, allowingReadAccessTo: url!)
        // Bundle.main.resourceURL!.appendingPathComponent("build")
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
