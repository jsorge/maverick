//
//  PostListController.swift
//  App
//
//  Created by Jared Sorge on 5/29/18.
//

import Foundation
import Leaf
import MaverickModels
import PathKit
import Vapor

struct PostListRouteCollection: RouteCollection {
    private let config: SiteConfig
    
    init(config: SiteConfig) {
        self.config = config
    }
    
    func boot(router: Router) throws {
        func fetchPostList(for page: Int, config: SiteConfig) throws -> Page {
            let postList = try PostListController.fetchPostList(forPageNumber: page, config: config)
            let outputPage = Page(style: .list(list: postList), site: config, title: config.title)
            return outputPage
        }
        
        // Home
        router.get("") { req -> Future<View> in
            let config = try SiteConfigController.fetchSite()
            let leaf = try req.make(LeafRenderer.self)
            let page = try fetchPostList(for: 1, config: config)
            return leaf.render("index", page)
        }
        
        // Archive
        router.get("page", Int.parameter) { req -> Future<View> in
            let config = try SiteConfigController.fetchSite()
            let leaf = try req.make(LeafRenderer.self)
            let page = try req.parameters.next(Int.self)
            let outputPage = try fetchPostList(for: page, config: config)
            return leaf.render("index", outputPage)
        }
    }
}

struct PostListController {
    static func fetchPostList(forPageNumber pageNumber: Int, config: SiteConfig) throws -> PostList {
        let allPostPaths = try PathHelper.pathsForAllPosts()
        
        let postsPaths = allPostPaths.compactMap({ PostPath(path: $0) })

        let batchStart = (pageNumber - 1) * config.batchSize
        var batchEnd = batchStart + config.batchSize
        if batchEnd > allPostPaths.count {
            batchEnd = allPostPaths.count - 1
        }
        let batchRange = batchStart..<batchEnd
        let neededPaths = Array(postsPaths[batchRange])

        let postController = PostController(site: config)
        let posts = neededPaths
                    .compactMap({ try? postController.fetchPost(withPath: $0, outputtingFor: .fullText) })
                    .sorted(by: { $0.date > $1.date })

        var pageCount = allPostPaths.count / config.batchSize
        if allPostPaths.count % config.batchSize != 0 {
            pageCount += 1
        }

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
