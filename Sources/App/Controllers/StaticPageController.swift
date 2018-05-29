//
//  StaticPageController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

enum StaticPageError: Error {
    case fileNotFound
}

struct StaticPageController {
    static private(set) var registeredPages = ["about"]
    
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
