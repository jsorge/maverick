//
//  Post.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import Logging

typealias Markdown = String

struct BasePost {
    let frontMatter: FrontMatter
    let content: Markdown
}

extension BasePost {
    var isMicropostLength: Bool {
        return content.count <= 280
    }
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
    let path: PostPath?
    let shortDescription: String?
    
    init(url: String, title: String?, content: String, frontMatter: FrontMatter, path: PostPath?)
    {
        self.date = frontMatter.date
        self.formattedDate = Post.dateFormatter.string(from: frontMatter.date)
        self.url = url
        self.title = title
        self.content = content
        self.isBlogPost = (frontMatter.isStaticPage == false)
        self.frontMatter = frontMatter
        self.path = path
        self.shortDescription = frontMatter.shortDescription
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
    let shortDescription: String
    
    private enum CodingKeys: String, CodingKey {
        case isMicroblog = "microblog"
        case title = "title"
        case layout = "layout"
        case guid = "guid"
        case date = "date"
        case isStaticPage = "staticpage"
        case shortDescription = "shortdescription"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isMicroblog = try container.decodeIfPresent(Bool.self, forKey: .isMicroblog) ?? false
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.layout = try container.decodeIfPresent(String.self, forKey: .layout)
        self.guid = try container.decodeIfPresent(String.self, forKey: .guid)
        self.isStaticPage = try container.decodeIfPresent(Bool.self, forKey: .isStaticPage) ?? false
        self.shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription) ?? ""
        
        // Dates are finicky.
        // We expect them to come in in `2018-07-11 06:29:36` format
        // But they could also come in `2018-08-01T01:57:13Z` format
        let dateString = try container.decode(String.self, forKey: .date)
        let date: Date
        if let parsedDate = FrontMatter.formatter.date(from: dateString) {
            date = parsedDate
        }
        else if let parsedDate = ISO8601DateFormatter().date(from: dateString) {
            date = parsedDate
        }
        else {
            date = Date()
            MaverickLogger.shared?.error("Error parsing date: \(dateString), for: \(self.title ?? "untitled")")
        }
        self.date = date
    }
}
