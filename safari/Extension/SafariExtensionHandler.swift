//
//  SafariExtensionHandler.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/13/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            
            switch messageName {
            case "setBadgeText":
                self.setBadgeText(userInfo)
            default:
                NSLog("Ignoring unknown message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            }
        }
    }
    
    func setBadgeText(_ userInfo: [String: Any]?) {
        guard let text = userInfo?["text"] else { return }
        NSLog("would set badge text to \(text)")
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
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

                    validationHandler(true, "")
                }
            }
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
