//
//  Post.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

struct BasePost {
    let frontMatter: FrontMatter
    let content: String
}

struct Post: Codable {
    var date: Date {
        return frontMatter.date
    }
    var formattedDate: String? {
        let formatter = DateFormatter()
        return formatter.string(from: date)
    }
    let url: String
    let title: String?
    let content: String
    let frontMatter: FrontMatter
    
    init(url: String, title: String?, content: String, frontMatter: FrontMatter) {
        self.url = url
        self.title = title
        self.content = content
        self.frontMatter = frontMatter
    }
}

struct FrontMatter: Codable {
    let isMicroblog: Bool = false
    let title: String?
    let layout: String?
    let guid: String?
    let date: Date
    let isStaticPage: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case isMicroblog = "microblog"
        case title = "title"
        case layout = "layout"
        case guid = "guid"
        case date = "date"
    }
}
