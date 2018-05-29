//
//  PostController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

struct PostPath {
    let year: Int
    let month: Int
    let day: Int
    let slug: String
    
    var asURIPath: String {
        return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))-\(slug)"
    }
}

struct PostController {
    static func fetchPost(withPath path: PostPath) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: path.asURIPath, in: .posts)
        
        var dateComponents = DateComponents()
        dateComponents.year = path.year
        dateComponents.month = path.month
        dateComponents.day = path.day
        
        let post = Post(date: dateComponents.date,
                        url: path.asURIPath,
                        title: base.frontMatter.title,
                        content: base.content,
                        frontMatter: base.frontMatter)
        return post
    }
}
