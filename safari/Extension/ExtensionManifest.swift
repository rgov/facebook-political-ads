//
//  ExtensionManifest.swift
//  Ad Collector Extension
//
//  Created by Ryan Govostes on 2/14/18.
//  Copyright © 2018 ProPublica. All rights reserved.
//

import Foundation

internal class ExtensionManifest: Codable {
    var background: Background?
    
    // File references will be relative to this baseURL
    var baseURL: URL?
    
    open static let `default`: ExtensionManifest = {
        let url = Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "dist")!
        return ExtensionManifest.load(fromURL: url)
    }()
    
    class func load(fromURL: URL) -> ExtensionManifest {
        let data = try! Data(contentsOf: fromURL, options: .mappedIfSafe)
        let instance = try! JSONDecoder().decode(ExtensionManifest.self, from: data)
        instance.baseURL = fromURL.deletingLastPathComponent()
        return instance
    }
    
    func urlForResource(named name: String) -> URL? {
        return baseURL?.appendingPathComponent(name)
    }
    
    func validate() {
        // TODO: It might be nice to cross-check the Info.plist with the
        // information in manifest.json
        fatalError("Manifest validation is not yet implemented")
    }
}

internal struct Background: Codable {
    var scripts: [String]?
    var pages: [String]?
}
