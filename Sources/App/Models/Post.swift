//
//  Post.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import SwiftMarkdown

struct BasePost {
    let frontMatter: FrontMatter
    let content: String
}

struct Post: Codable {
    let date: Date?
    var formattedDate: String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        return formatter.string(from: date)
    }
    let url: String
    let title: String?
    let content: String
    let frontMatter: FrontMatter
    
    init(date: Date?, url: String, title: String?, content: String, frontMatter: FrontMatter) {
        self.date = date
        self.url = url
        self.title = title
        self.content = (try? markdownToHTML(content, options: [.safe])) ?? "unable to parse the markdown"
        self.frontMatter = frontMatter
    }
}

struct FrontMatter: Codable {
    let isMicroblog: Bool = false
    let title: String?
    let layout: String?
    let guid: String?
    
    private enum CodingKeys: String, CodingKey {
        case isMicroblog = "microblog"
        case title = "title"
        case layout = "layout"
        case guid = "guid"
    }
}
