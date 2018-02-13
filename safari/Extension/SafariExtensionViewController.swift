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
        self.preferredContentSize = self.view.frame.size
        
        NSLog("webView is \(SafariExtensionViewController.shared.webView)")
        let myURL = URL(string: "https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
