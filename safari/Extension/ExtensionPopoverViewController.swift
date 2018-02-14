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


// MARK: - Messaging

extension ExtensionPopoverViewController: MessageDispatchTarget {
    func pushMessage(_ message: String, sender: String) {
        guard webView != nil else { return }
        webView.pushMessage(message, sender: sender)
    }
}


// MARK: - Resize to Fit

extension ExtensionPopoverViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Keep the popover's size constrained to document.body
        webView.getContentSize() { size in
            self.view.frame.size = size
            self.preferredContentSize = size
        }
    }
}
