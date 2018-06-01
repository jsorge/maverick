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
        let allPaths = try dirPath.children()
        
        let postsPaths = allPaths.compactMap({ PostPath(path: $0) })
        let allPosts = postsPaths.compactMap({ try? PostController.fetchPost(withPath: $0) })

        let batchRange = ((pageNumber - 1) * config.batchSize)...(pageNumber * (config.batchSize - 1))
        let posts = Array(allPosts[batchRange])

        let pageCount = allPaths.count / config.batchSize
        let olderLink: String?
        if pageNumber + 1 <= pageCount {
            olderLink = "/page/\(pageNumber + 1)"
        }
        else {
            olderLink = nil
        }

        let newerLink: String?
        if pageNumber - 1 == 1 {
            newerLink = "/"
        }
        else if pageNumber == 1 {
            newerLink = nil
        }
        else {
            newerLink = "/page/\(pageNumber - 1)"
        }

        let pagination = Pagination(newerLink: newerLink,
                                    olderLink: olderLink,
                                    pageNumber: "\(pageNumber) of \(pageCount)")
        
        let postList = PostList(posts: posts, pagination: pagination)
        return postList
    }
}
