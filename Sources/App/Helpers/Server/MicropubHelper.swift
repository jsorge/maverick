//
//  MicropubHelper.swift
//  App
//
//  Created by Jared Sorge on 6/11/18.
//

import Foundation
import Micropub
import PathKit
import Vapor

struct MicropubHelper {
    static func makeConfig(fromSite site: SiteConfig) -> MicropubConfig {
        let newPostHandler: NewPostHandler = { request throws in
            try PostConverter.saveMicropubPost(request)
        }

        let contentHandler: ContentReceivedHandler = { files throws in
            let incomingPath = PathHelper.incomingMediaPath
            for file in files {
                let filepath = incomingPath + Path(file.filename)
                try filepath.write(file.data)
            }

            // TODO: Run some method that attempts to embed the files in their textbundles
        }

        let config = MicropubConfig(url: site.url, postHandler: newPostHandler, contentHandler: contentHandler)
        return config
    }
}
