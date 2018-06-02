//
//  PostController.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

struct PostController {
    static func fetchPost(withPath path: PostPath) throws -> Post {
        let base = try FileReader.attemptToReadFile(named: path.asFilepath, in: .posts)
        let post = Post(url: path.asURIPath,
                        title: base.frontMatter.title,
                        content: base.content,
                        frontMatter: base.frontMatter)
        return post
    }
}
