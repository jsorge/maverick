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
    static func fetchSite() throws -> SiteConfig {
        let configPath = PathHelper.root + Path("SiteConfig.yml")
        guard configPath.exists else { throw FileReaderError.fileDoesNotExist }
        let data = try configPath.read()
        
        guard let congfigStr = String(data: data, encoding: .utf8)
            else { throw FileReaderError.unreadableFile }
        
        let decoder = YAMLDecoder()
        let config = try decoder.decode(SiteConfig.self, from: congfigStr)
        return config
    }
}
