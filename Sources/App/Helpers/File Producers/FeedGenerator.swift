//
//  FeedGenerator.swift
//  App
//
//  Created by Jared Sorge on 6/3/18.
//

import Foundation
import PathKit

protocol FeedGenerator {
    static func makeFeed(from posts: [Post], for site: SiteConfig, goingTo type: TextOutputType) -> String
    static func outputFileName(forType type: TextOutputType) -> String
}

struct FeedOutput {
    static func makeAllTheFeeds() throws {
        let generators: [FeedGenerator.Type] = [
            RSSFeedGenerator.self
        ]
        
        let site = try SiteConfigController.fetchSite()
        let controller = PostController(site: site)
        let paths = try PathHelper.pathsForAllPosts()
        
        for generator in generators {
            for outputType in TextOutputType.all {
                var posts = [Post]()
                for (index, path) in paths.enumerated() {
                    guard index < 50, let postPath = PostPath(path: path) else { break }
                    let post = try controller.fetchPost(withPath: postPath, outputtingFor: outputType)
                    posts.append(post)
                }
                
                let filename = generator.outputFileName(forType: outputType)
                let fileText = generator.makeFeed(from: posts, for: site, goingTo: outputType)
                let outputPath = PathHelper.publicFolderPath + Path(filename)
                try outputPath.write(fileText)
            }
        }
    }
}
