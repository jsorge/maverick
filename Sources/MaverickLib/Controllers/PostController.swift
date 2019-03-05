//
//  PostController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import Leaf
import MaverickModels
import SwiftMarkdown
import Vapor

enum PostControllerError: Error {
    case doesNotContainRequestedTag
}

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
                        return req.response(http: HTTPResponse(status: .notFound))
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
                    return req.response(http: response)
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
                let post = try StaticPageController.fetchStaticPage(named: slug, in: .drafts, for: self.config)
                let outputPage = Page(style: .single(post: post), site: self.config,
                                      title: post.title ?? self.config.title)
                
                var response = HTTPResponse()
                response.contentType = .html
                return leaf.render("post", outputPage).map { view -> Response in
                    response.body = HTTPBody(data: view.data)
                    return req.response(http: response)
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
    
    func fetchPost(withPath path: PostPath, outputtingFor output: TextOutputType, tag: Tag? = nil) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: path.asFilename, in: .posts)

        if let tag = tag {
            guard base.frontMatter.tags.contains(tag) else { throw PostControllerError.doesNotContainRequestedTag }
        }

        let formattedContent = try base.makeContent(for: output, path: path, site: _site)
        let title = base.frontMatter.title

        let post = Post(url: "\(_site.url)\(path.asURIPath)",
                        title: title,
                        content: formattedContent,
                        frontMatter: base.frontMatter,
                        path: path)
        return post
    }
    
    //MARK: - Private
    private let _site: SiteConfig
}

private extension BasePost {
    func makeContent(for outputType: TextOutputType, path: PostPath, site: SiteConfig) throws -> String {
        switch outputType {
        case .fullText:
            let assetsPath = PathHelper.makeBundleAssetsPath(filename: path.asFilename, location: .posts)
            let formattedContent = try FileProcessor.processMarkdownText(content, for: assetsPath)
            return formattedContent
        case .microblog:
            if isMicropost {
                return makeMicropostContent(with: path, site: site)
            }
            else {
                return makeContentForLongPostInMicroblogFeed(title: frontMatter.title, path: path, site: site)
            }
        }
    }

    private var isMicropost: Bool {
        let hasTitle = frontMatter.title != nil
        return hasTitle == false && frontMatter.isMicroblog
    }

    private var microPostMaxLength: Int { return 280 }

    private func makeContentForLongPostInMicroblogFeed(title: String?, path: PostPath, site: SiteConfig) -> String {
        let postHref = "\(site.url.appendingPathComponent(path.asURIPath))"
        var output = "New post from \(site.title): "

        if let title = title {
            output.append("[\(title)](\(postHref))")
        }
        else {
            output.append(postHref)
        }

        output = try! markdownToHTML(output)
        return output
    }

    private func makeMicropostContent(with path: PostPath, site: SiteConfig) -> String {
        var output = ""

        let padding = 5 // the number of characters represenging the `...\n\n` part of the post
        let postHref = "\(site.url.appendingPathComponent(path.asURIPath))"
        let postCharactersToTake = microPostMaxLength - postHref.count - padding
        let firstPart = String(content.prefix(postCharactersToTake))

        output = """
        \(firstPart)...

        \(postHref)
        """

        return output
    }
}
