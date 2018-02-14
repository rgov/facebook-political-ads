//
//  MessagingWebView.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/14/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import WebKit

class MessagingWebView: WKWebView {
    
    let dispatcher = MessageDispatcher()
    
    // MARK: - Initializers
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        injectGlueCode()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        injectGlueCode()
    }
    
    // MARK: - Glue Code
    
    private func injectGlueCode() {
        // Inject the glue code before every page load
        let url = Bundle.main.url(forResource: "safariglue", withExtension: "js")
        let source = try! String(contentsOf: url!, encoding: .utf8)
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        
        // Add a message handler that allows the glue code to call back to us
        configuration.userContentController.add(self, name: "bridge")
    }

}


// MARK: - Messaging

extension MessagingWebView: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard message.name == "bridge" else {
            NSLog("Message sent to message handler \"\(message.name)\" dropped")
            return
        }
        
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

extension MessagingWebView: MessageDispatchTarget {
    private func escape(_ str: String) -> String {
        return str.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
    }
    
    func pushMessage(_ message: String, sender: String) {
        self.evaluateJavaScript("glue.receiveMessage('\(escape(sender))', '\(escape(message))')") {
            _, error in
            
            guard error == nil else {
                NSLog("MessagingWebView.pushMessage() failed: \(error?.localizedDescription ?? "unknown")")
                return
            }
        }
    }
}
