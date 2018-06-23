//
//  SiteConfigController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import PathKit
import Yams

struct SiteConfigController {
    private static var currentConfig: SiteConfig?
    
    static func fetchSite() throws -> SiteConfig {
        guard currentConfig == nil else { return currentConfig! }
        
        let configPath = PathHelper.root + Path("SiteConfig.yml")
        do {
            let decoder = YAMLDecoder()
            let data = try configPath.read()
            
            guard let congfigStr = String(data: data, encoding: .utf8)
                else { throw FileReaderError.unreadableFile }
            
            let config = try decoder.decode(SiteConfig.self, from: congfigStr)
            currentConfig = config
            return config
        }
    }
}
