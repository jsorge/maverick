//
//  PostList.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

public struct PostList: Codable {
    public let posts: [Post]
    public let pagination: Pagination

    public init(posts: [Post], pagination: Pagination) {
        self.posts = posts
        self.pagination = pagination
    }
}

/// Placed at the bottom of post listing pages
public struct Pagination: Codable {
    /// Newer posts. Path only (like "/page/5". For home, supply "/".
    public let newerLink: String?
    /// Older posts. Path only (like "/page/3")
    public let olderLink: String?
    /// Text in the middle (like "2 of 32")
    public let pageNumber: String

    public init(newerLink: String?, olderLink: String?, pageNumber: String) {
        self.newerLink = newerLink
        self.olderLink = olderLink
        self.pageNumber = pageNumber
    }
}
