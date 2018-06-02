//
//  PathHelper.swift
//  App
//
//  Created by Jared Sorge on 6/2/18.
//

import Foundation
import PathKit
import Vapor

enum Location: String {
    case pages = "_pages"
    case posts = "_posts"
}

struct PathHelper {
    static func makeBundleAssetsPath(for filename: String, in location: Location) -> String {
        return "/\(location.rawValue)/\(filename).textbundle"
    }
    
    static var root: Path = {
        return Path(DirectoryConfig.detect().workDir)
    }()
    
    static var publicFolderPath: Path = {
        return root + Path("Public")
    }()
    
    static var postFolderPath: String = {
       let postsPath = root + Path(Location.posts.rawValue)
        return postsPath.string
    }()
    
    static func pathsForAllPosts() throws -> [Path] {
        let allPaths = try publicFolderPath.children()
            .sorted(by: { $0.lastComponentWithoutExtension > $1.lastComponentWithoutExtension })
        return allPaths
    }
}
