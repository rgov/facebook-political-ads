//
//  MessageDispatch.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/13/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

/*
 In the WebExtensions API, components of an extension can broadcast messages
 using (1) and receive them using (2). These APIs are not available to Safari
 App Extensions.
 
    1: browser.runtime.sendMessage()
    2: browser.runtime.onMessage.addListener()
 
 However, we can send messages from the content script to the app extension
 process using (3), and we can send messages from a WKWebView's JavaScript
 context using (4).
 
    3: safari.extension.dispatchMessage()
    4: window.webkit.messageHandlers.bridge.postNotification()
 
 This gives us one-way communication to the app extension. In turn, the app
 extension can communicate with the content script with (5) and (6).
 
    5: safari.self.addEventListener("message", handleMessage, false)
    6: SafariWebPageProxy.dispatchMessage()
 
 And lastly, we can push data into other WKWebViews simply by running some
 JavaScript (7).
 
    7: WKWebView.evaluateJavaScript()
 
 -------------
 
 Yuck. Our goal is to make all these Safari App Extension implementation details
 go away, and just emulate (1) and (2).
 
 For this to work, we need 
 */

protocol MessageDispatchTarget {
    func pushMessage(_ message: String, sender: String)
}

class MessageDispatcher: MessageDispatchTarget {
    var clients: [MessageDispatchTarget] = []
    
    func pushMessage(_ message: String, sender: String) {
        for client in clients {
            client.pushMessage(message, sender: sender)
        }
    }
}
