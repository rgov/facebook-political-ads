//
//  WebView+GetContentSize.swift
//  SafariExtension
//
//  Created by Ryan Govostes on 2/14/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import WebKit

extension WKWebView {
    func getContentSize(callback: @escaping ((NSSize) -> (Void))) {
        let js = "let css = window.getComputedStyle(document.body); [ css.width, css.height ]"
        self.evaluateJavaScript(js) {
            result, error in
            
            guard let result = result as? [String], error == nil else {
                NSLog("Failed to get preferred content size: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            let width = (result[0] as NSString).floatValue
            let height = (result[1] as NSString).floatValue
            callback(NSMakeSize(CGFloat(width), CGFloat(height)))
        }
    }
}
