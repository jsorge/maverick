//
//  PostList.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

struct PostList: Codable {
    let posts: [Post]
    let pagination: Pagination
}

/// Placed at the bottom of post listing pages
struct Pagination: Codable {
    /// Newer posts. Path only (like "/page/5". For home, supply "/".
    let newerLink: String?
    /// Older posts. Path only (like "/page/3")
    let olderLink: String?
    /// Text in the middle (like "2 of 32")
    let pageNumber: String
}
