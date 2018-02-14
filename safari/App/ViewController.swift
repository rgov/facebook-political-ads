//
//  ViewController.swift
//  Facebook Political Ad Collector
//
//  Created by Ryan Govostes on 2/13/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import Cocoa
import SafariServices
import WebKit

class ViewController: NSViewController {
    private var isSafariExtensionEnabled = false
    
    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start monitoring for state changes
        self.watchSafariExtensionState()

        // Load the embedded HTML file
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "content")
        // let dir = Bundle.main.resourceURL!.appendingPathComponent("content", isDirectory: true)
        webView.loadFileURL(url!, allowingReadAccessTo: url!)
    }
}


// MARK: - Safari State

extension ViewController {
    private func watchSafariExtensionState() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "org.propublica.FacebookAdCollector.Extension") { state, error in
                
                guard error == nil, state != nil else {
                    NSLog("Could not get extension state: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                if state!.isEnabled != self.isSafariExtensionEnabled {
                    self.isSafariExtensionEnabled = state!.isEnabled
                    self.safariExtensionStateChanged()
                }
                
            }
        }
    }
    
    private func safariExtensionStateChanged() {
        guard webView != nil else { return }
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("document.body.innerText = '\(self.isSafariExtensionEnabled)'")
        }
    }
}


// MARK: - Resize to Fit

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.getContentSize() { size in
            self.view.window!.setContentSize(size)
            self.view.window!.center()
        }
    }
}

