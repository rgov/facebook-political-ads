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

    private let webView = WKWebView()
    
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
        dispatcher.clients.append(SafariExtensionViewController.shared)
        
        injectGlueCode()
    }
    
    // Copy & pasted from SafariExtensionViewController.swift, TODO: refactor
    private func injectGlueCode() {
        let url = Bundle.main.url(forResource: "safariglue", withExtension: "js")
        let source = try! String(contentsOf: url!, encoding: .utf8)
        
        let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        let ucctrl = webView.configuration.userContentController
        ucctrl.add(self, name: "bridge")
        ucctrl.addUserScript(userScript)
    }
}



// Copy & pasted from SafariExtensionViewController.swift, TODO: refactor
extension BackgroundScript: MessageDispatchTarget {
    private func escape(_ str: String) -> String {
        return str.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
    }
    
    func pushMessage(_ message: String, sender: String) {
        // FIXME: Implement string escaping (urgent)
        webView.evaluateJavaScript("glue.receiveMessage('\(escape(sender))', '\(escape(message))')") {
            _, error in
            
            guard error == nil else {
                NSLog("BackgroundScript failed: \(error?.localizedDescription ?? "unknown")")
                return
            }
        }
    }
}

extension BackgroundScript: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let name = message.name
        guard let bodyDict = message.body as? [String: String] else {
            NSLog("BackgroundScript: Message \(name) is in an unsupported format")
            return
        }
        guard let sender = bodyDict["sender"] else {
            NSLog("BackgroundScript: Message \(name) is missing the sender field")
            return
        }
        guard let body = bodyDict["body"] else {
            NSLog("BackgroundScript: Message \(name) is missing the body field")
            return
        }
        
        if name != "dispatchMessage" {
            NSLog("SafariExtensionViewController: Dropping message \(name)")
            return
        }
        
        // Forward it
        NSLog("BackgroundScript: Forwarding message \(body) from \(sender)")
        dispatcher.pushMessage(body, sender: sender)
    }
}
