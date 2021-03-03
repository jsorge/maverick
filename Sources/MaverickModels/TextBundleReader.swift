//
//  TextBundleReader.swift
//  MaverickModels
//
//  Created by Jared Sorge on 11/5/19.
//

import Foundation
import Pathos

public enum FileReaderError: Error {
    case unreadableFile(String)
}

public struct TextBundleReader {
    public static func attemptToReadFile(at bundlePath: String) throws -> BasePost {
        let path = Path(bundlePath)
        let infoPath = path + Path("info.json")
        let textPath = path + Path("text.md")

        let markdown = try textPath.readUTF8String()

        guard
            let bundleData = try infoPath.readUTF8String().data(using: .utf8),
            let bundleInfo = BundleInfo(json: bundleData),
            let frontMatter = bundleInfo.frontMatter else
        {
            throw FileReaderError.unreadableFile(bundlePath)
        }

        let post = BasePost(frontMatter: frontMatter, content: markdown)
        return post
    }
}
