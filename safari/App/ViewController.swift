//
//  ViewController.swift
//  Facebook Political Ad Collector
//
//  Created by Ryan Govostes on 2/13/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the popup resource file
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "content")
        // let dir = Bundle.main.resourceURL!.appendingPathComponent("content", isDirectory: true)
        webView.loadFileURL(url!, allowingReadAccessTo: url!)
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

