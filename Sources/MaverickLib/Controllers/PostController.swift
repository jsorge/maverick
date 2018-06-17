//
//  PostController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

struct PostController {
    init(site: SiteConfig) {
        _site = site
    }
    
    func fetchPost(withPath path: PostPath, outputtingFor output: TextOutputType) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: path.asFilename, in: .posts)
        
        let formattedContent: String
        switch (output, base.isMicropostLength) {
        case (.fullText, _), (.microblog, true):
            let assetsPath = PathHelper.makeBundleAssetsPath(filename: path.asFilename, location: .posts)
            formattedContent = try FileProcessor.processMarkdownText(base.content, for: assetsPath)
        case (.microblog, false):
            formattedContent = makeContentForLongPostInMicroblogFeed(title: base.frontMatter.title, path: path)
        }
        
        let post = Post(url: path.asURIPath,
                        title: base.frontMatter.title,
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
            output.append("[\(title)](\(postHref)")
        }
        else {
            output.append(postHref)
        }
        
        return output
    }
}
