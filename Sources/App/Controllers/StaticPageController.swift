//
//  StaticPageController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import PathKit
import Vapor

struct StaticPageController {
    static var registeredPages: [String] {
        let dirPath = Path(DirectoryConfig.detect().workDir) + Path("Public/\(Location.pages.rawValue)")
        do {
            let children = try dirPath.children()
            return children.map { $0.lastComponentWithoutExtension }
        } catch {
            return []
        }
    }

    static func fetchStaticPage(named pageName: String) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: pageName, in: .pages)
        let post = Post(url: "/\(pageName)",
                        title: base.frontMatter.title,
                        content: base.content,
                        frontMatter: base.frontMatter)
        return post
    }
}
