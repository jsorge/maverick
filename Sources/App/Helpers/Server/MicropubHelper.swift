//
//  MicropubHelper.swift
//  App
//
//  Created by Jared Sorge on 6/11/18.
//

import Foundation
import Micropub

struct MicropubHelper {
    static func makeConfig(fromSite site: SiteConfig) -> MicropubConfig {
        let newPostHandler: NewPostHandler = { request throws in
            try PostConverter.saveMicropubPost(request)
        }

        let config = MicropubConfig(url: site.url, postHandler: newPostHandler)
        return config
    }
}
