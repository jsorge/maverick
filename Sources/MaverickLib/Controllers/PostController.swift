//
//  PostController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import Leaf
import SwiftMarkdown
import Vapor

struct SinglePostRouteCollection: RouteCollection {
    let config: SiteConfig
    
    init(config: SiteConfig) {
        self.config = config
    }
    
    func boot(router: Router) throws {
        func attemptToFindPost(withSlug slug: String, for req: Request) throws -> Future<Response> {
            let posts = try PathHelper.pathsForAllPosts()
            guard let filePath = posts.filter({ $0.lastComponentWithoutExtension.contains(slug) }).first,
                let postPath = PostPath(path: filePath) else {
                    return Future.map(on: req) {
                        return req.makeResponse(http: HTTPResponse(status: .notFound))
                    }
            }
            
            let urlPath = self.config.url.appendingPathComponent(postPath.asURIPath)
            return Future.map(on: req) {
                return req.redirect(to: urlPath.absoluteString, type: .permanent)
            }
        }
        
        router.get(Int.parameter, Int.parameter, Int.parameter, String.parameter) { req -> Future<Response> in
            let leaf = try req.make(LeafRenderer.self)
            
            let year = try req.parameters.next(Int.self)
            let month = try req.parameters.next(Int.self)
            let day = try req.parameters.next(Int.self)
            let slug = try req.parameters.next(String.self)
            let path = PostPath(year: year, month: month, day: day, slug: slug)
            
            do {
                let postController = PostController(site: self.config)
                let post = try postController.fetchPost(withPath: path, outputtingFor: .fullText)
                let outputPage = Page(style: .single(post: post), site: self.config, title: post.title ?? self.config.title)
                
                var response = HTTPResponse()
                response.contentType = .html
                return leaf.render("post", outputPage).map { view -> Response in
                    response.body = HTTPBody(data: view.data)
                    return req.makeResponse(http: response)
                }
            }
            catch {
                return try attemptToFindPost(withSlug: path.slug, for: req)
            }
        }
        
        router.get("draft", String.parameter) { req -> Future<Response> in
            let leaf = try req.make(LeafRenderer.self)
            let slug = try req.parameters.next(String.self)
            
            do {
                let post = try StaticPageController.fetchStaticPage(named: slug, in: .drafts)
                let outputPage = Page(style: .single(post: post), site: self.config,
                                      title: post.title ?? self.config.title)
                
                var response = HTTPResponse()
                response.contentType = .html
                return leaf.render("post", outputPage).map { view -> Response in
                    response.body = HTTPBody(data: view.data)
                    return req.makeResponse(http: response)
                }
            }
            catch {
                return try attemptToFindPost(withSlug: slug, for: req)
            }
        }
    }
}

struct PostController {
    init(site: SiteConfig) {
        _site = site
    }
    
    func fetchPost(withPath path: PostPath, outputtingFor output: TextOutputType) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: path.asFilename, in: .posts)
        
        let formattedContent: String
        let title: String?
        switch (output, base.isMicropostLength) {
        case (.fullText, _), (.microblog, true):
            let assetsPath = PathHelper.makeBundleAssetsPath(filename: path.asFilename, location: .posts)
            formattedContent = try FileProcessor.processMarkdownText(base.content, for: assetsPath)
            title = base.frontMatter.title
        case (.microblog, false):
            formattedContent = makeContentForLongPostInMicroblogFeed(title: base.frontMatter.title, path: path)
            title = nil
        }
        
        let post = Post(url: path.asURIPath,
                        title: title,
                        content: formattedContent,
                        frontMatter: base.frontMatter,
                        path: path)
        return post
    }
    
    //MARK: - Private
    private let _site: SiteConfig
    
    private func makeContentForLongPostInMicroblogFeed(title: String?, path: PostPath) -> String {
        let postHref = "\(_site.url.appendingPathComponent(path.asURIPath))"
        var output = "New post from \(_site.title): "
        
        if let title = title {
            output.append("[\(title)](\(postHref))")
        }
        else {
            output.append(postHref)
        }
        
        output = try! markdownToHTML(output)
        return output
    }
}
