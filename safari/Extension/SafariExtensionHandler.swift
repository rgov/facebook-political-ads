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
        dispatcher.clients.append(BackgroundScript.shared)
        dispatcher.clients.append(SafariExtensionViewController.shared)
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
    
    // Only enable the toolbar button on *.facebook.com
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        window.getActiveTab { tab in
            guard let tab = tab else { validationHandler(false, ""); return }
            tab.getActivePage { page in
                guard let page = page else { validationHandler(false, ""); return }
                page.getPropertiesWithCompletionHandler { properties in
                    guard let properties = properties else { validationHandler(false, ""); return }
                    guard let host = properties.url?.host else { validationHandler(false, ""); return }
                    
                    guard host.range(of: "(^|[.])facebook.com$", options: .regularExpression, range: nil, locale: nil) != nil else {
                        validationHandler(false, "")
                        return
                    }

                    validationHandler(true, self.badgeText)
                }
            }
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}

