//
//  Page.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

public enum CodingError: Error {
    case decoding(message: String)
}

/// A page is what gets rendered by the browser
public struct Page: Codable {
    public let style: Style
    public let site: SiteConfig
    public let title: String

    public init (style: Style, site: SiteConfig, title: String) {
        self.style = style
        self.site = site
        self.title = title
    }
}

extension Page {
    /// Defines the different styles that a page can present
    public enum Style: Codable {
        /// A single post
        case single(post: Post)
        /// A list of posts
        case list(list: PostList)

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let post = try? container.decode(Post.self, forKey: .post) {
                self = .single(post: post)
            } else if let list = try? container.decode(PostList.self, forKey: .list) {
                self = .list(list: list)
            }

            throw CodingError.decoding(message: "Decoding error: \(dump(container))")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .list(let list):
                try container.encode(list, forKey: .list)
            case .single(let post):
                try container.encode(post, forKey: .post)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case post
            case list
        }
    }
}
