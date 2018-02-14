//
//  SafariExtensionHandler.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/13/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import SafariServices

// MARK: - Message Dispatch

class SafariExtensionHandler: SFSafariExtensionHandler {
    let dispatcher = MessageDispatcher()
    var badgeText = ""
    
    override init() {
        super.init()
        
        // Do not register ourselves with the dispatcher; the documentation for
        // chrome.runtime.sendMessage() says that it doesn't send to content
        // scripts (such messages should be sent to a specific tab)
        dispatcher.clients.append(BackgroundScriptManager.default)
        dispatcher.clients.append(ExtensionPopoverViewController.shared)
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        
        let name = messageName
        guard let sender = userInfo?["sender"] as? String else {
            NSLog("Message \(name) is missing the sender field")
            return
        }
        guard let body = userInfo?["body"] as? String else {
            NSLog("Message \(name) is missing the body field")
            return
        }
        
        switch (name) {
        case "dispatchMessage":
            // Just forward this message on for other scripts
            dispatcher.pushMessage(body, sender: sender)
        case "setBadgeText":
            setBadgeText(body)
        default:
            NSLog("Unhandled message \(name)")
        }
    }
    
    func setBadgeText(_ body: String) {
        do {
            guard let data = body.data(using: .utf8) else { return }
            badgeText = try JSONDecoder().decode(String.self, from: data)
            SFSafariApplication.setToolbarItemsNeedUpdate()
        } catch {
            return
        }
    }
}

// MARK: - Toolbar Item

extension SafariExtensionHandler {
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, self.badgeText)
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return ExtensionPopoverViewController.shared
    }

}

