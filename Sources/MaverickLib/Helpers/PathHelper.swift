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
    static func makeBundleAssetsPath(filename: String, location: Location) -> String {
        return "/\(location.rawValue)/\(filename).textbundle"
    }
    
    static var root: Path = {
        if isDebug() {
            return Path(DirectoryConfig.detect().workDir) + Path("_dev")
        }
        else {
            return Path(DirectoryConfig.detect().workDir)
        }
    }()
    
    static var publicFolderPath: Path = {
        return root + Path("Public")
    }()
    
    static var postFolderPath: Path = {
       let postsPath = publicFolderPath + Path(Location.posts.rawValue)
        return postsPath
    }()
    
    static func pathsForAllPosts() throws -> [Path] {
        let allPaths = try postFolderPath.children()
            .sorted(by: { $0.lastComponentWithoutExtension > $1.lastComponentWithoutExtension })
        return allPaths
    }

    static func prepTheTemporaryPaths() throws {
        try incomingPostPath.mkpath()
        try incomingMediaPath.mkpath()
    }

    static var incomingFolderPath: Path = {
        return publicFolderPath + Path("incoming")
    }()

    static var incomingPostPath: Path = {
        return incomingFolderPath + Path("posts")
    }()

    static var incomingMediaPath: Path = {
        return incomingFolderPath + Path("media")
    }()
}
