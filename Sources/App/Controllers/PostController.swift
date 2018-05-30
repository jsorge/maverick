//
//  PostController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import PathKit

struct PostPath {
    let year: Int
    let month: Int
    let day: Int
    let slug: String
    
    var asURIPath: String {
        return "\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))/\(slug)"
    }
    
    var asFilepath: String {
        return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))-\(slug)"
    }
    
    init(year: Int, month: Int, day: Int, slug: String) {
        self.year = year
        self.month = month
        self.day = day
        self.slug = slug
    }
    
    init?(path: Path) {
        guard path.string.contains(".DS_Store") == false else { return nil }
        
        var components = path.lastComponentWithoutExtension.split(separator: "-")
        let _day = components[2]
        let _month = components[1]
        let _year = components[0]
        let slug = components.dropFirst(3).joined(separator: "-")
        
        guard let day = Int(_day), let month = Int(_month), let year = Int(_year) else { return nil }
        
        self.year = year
        self.month = month
        self.day = day
        self.slug = String(slug)
    }
}

struct PostController {
    static func fetchPost(withPath path: PostPath) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: path.asFilepath, in: .posts)
        
        var dateComponents = DateComponents()
        dateComponents.year = path.year
        dateComponents.month = path.month
        dateComponents.day = path.day
        
        let post = Post(date: nil,
                        url: path.asURIPath,
                        title: base.frontMatter.title,
                        content: base.content,
                        frontMatter: base.frontMatter)
        return post
    }
}
