//
//  StaticPageController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import PathKit

struct StaticPageController {
    static var registeredPages: [String] {
        let dirPath = PathHelper.root + Path("Public/\(Location.pages.rawValue)")
        do {
            let children = try dirPath.children()
            return children.map { $0.lastComponentWithoutExtension }
        } catch {
            return []
        }
    }

    static func fetchStaticPage(named pageName: String) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: pageName, in: .pages)
        let assetsPath = PathHelper.makeBundleAssetsPath(filename: pageName, location: .pages)
        let formattedContent = try FileProcessor.processMarkdownText(base.content, for: assetsPath)
        let post = Post(url: "/\(pageName)",
                        title: base.frontMatter.title,
                        content: formattedContent,
                        frontMatter: base.frontMatter,
                        path: nil)
        return post
    }
}
