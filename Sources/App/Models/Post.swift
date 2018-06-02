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
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    let date: Date
    let formattedDate: String
    let url: String
    let title: String?
    let content: String
    let isBlogPost: Bool
    let frontMatter: FrontMatter
    
    init(url: String, title: String?, content: String, frontMatter: FrontMatter) {
        self.date = frontMatter.date
        self.formattedDate = Post.dateFormatter.string(from: frontMatter.date)
        self.url = url
        self.title = title
        self.content = content
        self.isBlogPost = (frontMatter.isStaticPage == false)
        self.frontMatter = frontMatter
    }
}

struct FrontMatter: Codable {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withDashSeparatorInDate,
            .withTime,
            .withSpaceBetweenDateAndTime,
            .withColonSeparatorInTime
        ]
        return formatter
    }()
    
    let isMicroblog: Bool
    let title: String?
    let layout: String?
    let guid: String?
    let date: Date
    let isStaticPage: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isMicroblog = "microblog"
        case title = "title"
        case layout = "layout"
        case guid = "guid"
        case date = "date"
        case isStaticPage = "staticpage"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isMicroblog = try container.decodeIfPresent(Bool.self, forKey: .isMicroblog) ?? false
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.layout = try container.decodeIfPresent(String.self, forKey: .layout)
        self.guid = try container.decodeIfPresent(String.self, forKey: .guid)
        let dateString = try container.decode(String.self, forKey: .date)
        self.date = FrontMatter.formatter.date(from: dateString)!
        self.isStaticPage = try container.decodeIfPresent(Bool.self, forKey: .isStaticPage) ?? false
    }
}
