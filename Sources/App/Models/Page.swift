//
//  Page.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

enum CodingError: Error {
    case decoding(message: String)
}

struct Page: Codable {
    enum Style: Codable {
        case single(post: Post)
        case list(list: PostList)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let post = try? container.decode(Post.self, forKey: .post) {
                self = .single(post: post)
            } else if let list = try? container.decode(PostList.self, forKey: .list) {
                self = .list(list: list)
            }
            
            throw CodingError.decoding(message: "Decoding error: \(dump(container))")
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .list(let list):
                try container.encode(list, forKey: .list)
            case .single(let post):
                try container.encode(post, forKey: .post)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case post
            case list
        }
    }
    
    let style: Style
    let site: SiteConfig
    let title: String
}
