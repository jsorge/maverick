//
//  PostListController.swift
//  App
//
//  Created by Jared Sorge on 5/29/18.
//

import Foundation
import PathKit
import Vapor

struct PostListController {
    static func fetchPostList(forPageNumber pageNumber: Int, config: SiteConfig) throws -> PostList {
        let dirPath = Path(DirectoryConfig.detect().workDir) + Path("Public/\(Location.posts.rawValue)")
        let children = try dirPath.children()
        
        let adjustedPage = pageNumber - 1
        let batchRange = (adjustedPage * config.batchSize)...(adjustedPage + 1 * (config.batchSize - 1))
        let filepaths = children[batchRange]
        
        let postsPaths = filepaths.compactMap({ PostPath(path: $0) })
        let posts = postsPaths.compactMap({ try? PostController.fetchPost(withPath: $0) })
        
        let newerLink = "page/\(pageNumber + 1)"
        let olderLink = "page/\(pageNumber - 1)"
        let numberOfPages = children.count / config.batchSize
        let pagination = Pagination(newerLink: newerLink,
                                    olderLink: olderLink,
                                    pageNumber: "\(pageNumber) of \(numberOfPages)")
        
        let postList = PostList(posts: posts, pagination: pagination)
        return postList
    }
}
