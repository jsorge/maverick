//
//  StaticPageController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import PathKit
import Vapor

enum StaticPageError: Error {
    case fileNotFound
}

struct StaticPageController {
    static private(set) var registeredPages: [String] = {
        let dirPath = Path(DirectoryConfig.detect().workDir) + Path("Public/\(Location.pages.rawValue)")
        do {
            let children = try dirPath.children()
            return children.map { $0.lastComponentWithoutExtension }
        } catch {
            return []
        }
    }()
    
    static func fetchStaticPage(named pageName: String) throws -> Post {
        guard self.registeredPages.contains(pageName) else { throw StaticPageError.fileNotFound }
        
        let base = try FileReader.attemptToReadFile(named: pageName, in: .pages)
        let post = Post(date: nil,
                        url: "/\(pageName)",
                        title: base.frontMatter.title,
                        content: base.content,
                        frontMatter: base.frontMatter)
        return post
    }
}
