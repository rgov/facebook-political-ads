//
//  BackgroundScriptManager.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/14/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import Foundation

class BackgroundScriptManager {
    static let `default` = BackgroundScriptManager(fromManifest: .default)
    
    var scripts: [BackgroundScript] = []

    convenience init (fromManifest manifest: ExtensionManifest) {
        self.init()
        manifest.background?.scripts?.forEach { js in
            if let url = manifest.urlForResource(named: js) {
                scripts.append(BackgroundScript(withJavaScriptFrom: url, baseURL: manifest.baseURL))
            }
        }
        manifest.background?.pages?.forEach { html in
            if let url = manifest.urlForResource(named: html) {
                scripts.append(BackgroundScript(withHTMLFrom: url, baseURL: manifest.baseURL))
            }
        }
    }
}

extension BackgroundScriptManager: MessageDispatchTarget {
    func pushMessage(_ message: String, sender: String) {
        // Just forward the message to everyone else
        for script in scripts {
            script.pushMessage(message, sender: sender)
        }
    }
}
