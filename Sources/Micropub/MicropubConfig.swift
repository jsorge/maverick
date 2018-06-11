//
//  MicropubConfig.swift
//  App
//
//  Created by Jared Sorge on 6/11/18.
//

import Foundation

public typealias NewPostHandler = (_ request: MicropubBlogPostRequest) throws -> ()

public struct MicropubConfig {
    let url: URL
    let newPostHandler: NewPostHandler

    public init(url: URL, postHandler: @escaping NewPostHandler) {
        self.url = url
        self.newPostHandler = postHandler
    }
}
