//
//  BackgroundScript.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/14/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import WebKit

class BackgroundScript: NSObject {
    // Yuck
    static let shared = BackgroundScript()
    
    let dispatcher = MessageDispatcher()

    private let webView = MessagingWebView()
    
    private let default_html = """
    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="UTF-8">
            <title>Background Script Host</title>
        </head>
        <body>
            <script type="text/javascript" src="<%placeholder%>"></script>
        </body>
    </html>
    """
    
    convenience init (withJavaScriptFrom url: URL, baseURL: URL?) {
        self.init()
        // TODO: How can we restrict what resources are available?
        let html = default_html.replacingOccurrences(of: "<%placeholder%>", with: url.absoluteString)
        webView.loadHTMLString(html, baseURL: baseURL)
    }
    
    convenience init (withHTMLFrom url: URL, baseURL: URL?) {
        self.init()
        webView.loadFileURL(url, allowingReadAccessTo: baseURL ?? url)
    }
    
    override init() {
        super.init()
        
        // Yuck
        dispatcher.clients.append(ExtensionPopoverViewController.shared)
    }
}

extension BackgroundScript: MessageDispatchTarget {
    func pushMessage(_ message: String, sender: String) {
        // Forward to the webview
        webView.pushMessage(message, sender: sender)
    }
}
