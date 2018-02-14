//
//  SafariExtensionViewController.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/13/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import SafariServices
import WebKit

class ExtensionPopoverViewController: SFSafariExtensionViewController {
    static let shared = ExtensionPopoverViewController()
    
    let dispatcher = MessageDispatcher()
    
    @IBOutlet weak var webView: MessagingWebView!
    
    override func viewDidLoad() {
        // Yuck
        dispatcher.clients.append(BackgroundScriptManager.default)
        
        // This sets the default size of the popover, before the HTML has loaded
        self.preferredContentSize = self.view.frame.size
        
        // Load the popup resource file
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "dist")
        //let dir = Bundle.main.resourceURL!.appendingPathComponent("dist", isDirectory: true)
        webView.loadFileURL(url!, allowingReadAccessTo: url!)
    }
}


// MARK: - Resizing

extension ExtensionPopoverViewController: WKNavigationDelegate {
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Keep the popover's size constrained to document.body
        resizeToContent()
    }
}


// MARK: - Messaging

extension ExtensionPopoverViewController: MessageDispatchTarget {
    func pushMessage(_ message: String, sender: String) {
        guard webView != nil else { return }
        webView.pushMessage(message, sender: sender)
    }
}
