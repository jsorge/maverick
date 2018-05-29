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
