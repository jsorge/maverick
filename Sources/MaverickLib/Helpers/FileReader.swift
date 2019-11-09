//
//  FileReader.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import MaverickModels
import PathKit

struct FileReader {
    static func attemptToReadFile(named filename: String, in location: Location) throws -> BasePost {
        let dirPath = PathHelper.publicFolderPath + Path("\(location.rawValue)")
        let bundlepath = dirPath + Path("\(filename).textbundle")

        let post = try TextBundleReader.attemptToReadFile(at: bundlepath.string)
        return post
    }
}
