//
//  Post.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

public typealias Markdown = String

/// A basic container for an unformatted post.
public struct BasePost {
    public let frontMatter: FrontMatter
    public let content: Markdown

    public init(frontMatter: FrontMatter, content: Markdown) {
        self.frontMatter = frontMatter
        self.content = content
    }
}

/// A formatted post, ready to be sent wherever it needs to go (the website or as a generated feed item)
public struct Post: Codable {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    public let date: Date
    /// The date as it appears on the website
    public let formattedDate: String
    public let url: String
    public let title: String?
    public let content: String
    /// Differentiates a blog post from a static page
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
