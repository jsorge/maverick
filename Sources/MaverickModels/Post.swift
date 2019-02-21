//
//  Post.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

public typealias Markdown = String

public struct BasePost {
    public let frontMatter: FrontMatter
    public let content: Markdown

    public init(frontMatter: FrontMatter, content: Markdown) {
        self.frontMatter = frontMatter
        self.content = content
    }
}

public struct Post: Codable {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    public let date: Date
    public let formattedDate: String
    public let url: String
    public let title: String?
    public let content: String
    public let isBlogPost: Bool
    public let frontMatter: FrontMatter
    public let path: PostPath?
    public let shortDescription: String?

    public init(url: String, title: String?, content: String, frontMatter: FrontMatter, path: PostPath?)
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

public struct FrontMatter: Codable {
    public static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [ .withInternetDateTime ]
        return formatter
    }()

    private static let deprecatedFormatter: ISO8601DateFormatter = {
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

    public let isMicroblog: Bool
    public let title: String?
    public let layout: String?
    public let guid: String?
    public let date: Date
    public let isStaticPage: Bool
    public let shortDescription: String

    private enum CodingKeys: String, CodingKey {
        case isMicroblog = "microblog"
        case title = "title"
        case layout = "layout"
        case guid = "guid"
        case date = "date"
        case isStaticPage = "staticpage"
        case shortDescription = "shortdescription"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isMicroblog = try container.decodeIfPresent(Bool.self, forKey: .isMicroblog) ?? false
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.layout = try container.decodeIfPresent(String.self, forKey: .layout)
        self.guid = try container.decodeIfPresent(String.self, forKey: .guid)
        self.isStaticPage = try container.decodeIfPresent(Bool.self, forKey: .isStaticPage) ?? false
        self.shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription) ?? ""

        // Dates are finicky.
        // Dates now need to be in internet time (RFC 3339)
        // We initially expected them to come in in `2018-07-11 06:29:36` format
        // But they could also come in `2018-08-01T01:57:13Z` format
        let dateString = try container.decode(String.self, forKey: .date)
        let date: Date
        if let parsedDate = FrontMatter.dateFormatter.date(from: dateString) {
            date = parsedDate

        }
        else if let parsedDate = FrontMatter.deprecatedFormatter.date(from: dateString) {
            date = parsedDate
        }
        else if let parsedDate = ISO8601DateFormatter().date(from: dateString) {
            date = parsedDate
        }
        else {
            date = Date()
        }
        self.date = date
    }
}
