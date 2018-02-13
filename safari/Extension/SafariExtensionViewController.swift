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
    
    let dispatcher = MessageDispatcher()
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        // Yuck
        dispatcher.clients.append(BackgroundScript.shared)
        
        injectGlueCode()
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "dist")
        webView.loadFileURL(url!, allowingReadAccessTo: url!)
        // Bundle.main.resourceURL!.appendingPathComponent("dist")
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

extension SafariExtensionViewController: MessageDispatchTarget {
    private func escape(_ str: String) -> String {
        return str.replacingOccurrences(of: "\\", with: "\\\\")
                  .replacingOccurrences(of: "'", with: "\\'")
    }
    
    func pushMessage(_ message: String, sender: String) {
        guard webView != nil else {
            NSLog("SafariExtensionViewController: Dropping message because popover not ready");
            return
        }
        
        // FIXME: Implement string escaping (urgent)
        webView.evaluateJavaScript("glue.receiveMessage('\(escape(sender))', '\(escape(message))')") {
            _, error in
            
            guard error == nil else {
                NSLog("SafariExtensionViewController failed: \(error?.localizedDescription ?? "unknown")")
                return
            }
        }
    }
}

extension SafariExtensionViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let contents = message.body as? [String: Any] else {
            NSLog("SafariExtensionViewController: Message is in an unsupported format")
            return
        }
        
        guard let name = contents["name"] as? String else {
            NSLog("SafariExtensionViewController: Message is missing the name field")
            return
        }
        guard let sender = contents["sender"] as? String else {
            NSLog("SafariExtensionViewController: Message \(name) is missing the sender field")
            return
        }
        guard let body = contents["body"] as? String else {
            NSLog("SafariExtensionViewController: Message \(name) is missing the body field")
            return
        }
        
        if name != "dispatchMessage" {
            NSLog("SafariExtensionViewController: Dropping message \(name)")
            return
        }

        // Forward it
        NSLog("SafariExtensionViewController: Forwarding message \(body) from \(sender)")
        dispatcher.pushMessage(body, sender: sender)
    }
}
