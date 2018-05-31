//
//  FileReader.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation
import PathKit
import Vapor
import Yams

enum Location: String {
    case pages = "_pages"
    case posts = "_posts"
}

enum FileReaderError: Error {
    case unreadableFile
}

struct FileReader {
    static func attemptToReadFile(named filename: String, in location: Location) throws -> BasePost {
        let dirPath = Path(DirectoryConfig.detect().workDir) + Path("Public/\(location.rawValue)")
        let bundlepath = dirPath + Path("\(filename).textbundle")
        let filepath = bundlepath + Path("text.md")
        
        let fileData: Data
        do {
            fileData = try filepath.read()
        }
        
        guard let fileContents = String(data: fileData, encoding: .utf8) else {
            throw FileReaderError.unreadableFile
        }
        
        let raw = RawPost()
        let lines = fileContents.split(maxSplits: Int.max, omittingEmptySubsequences: false,
                                       whereSeparator: { return $0 == "\n"})
        for line in lines {
            raw.importText(String(line))
        }
        
        let decoder = YAMLDecoder()
        let frontMatter = try decoder.decode(FrontMatter.self, from: raw.frontMatter)
        let post = BasePost(frontMatter: frontMatter, content: raw.content)
        return post
    }
}

private final class RawPost {
    private enum ReadState {
        case frontMatter
        case content
    }
    
    private(set) var frontMatter = ""
    private(set) var content = ""
    
    private let frontMatterSeparator = "---"
    private var foundSeparators = 0
    private var state: ReadState {
        return foundSeparators < 2 ? .frontMatter : .content
    }
    
    func importText(_ text: String) {
        if text == frontMatterSeparator {
            foundSeparators += 1
            return
        }
        
        switch state {
        case .frontMatter:
            if frontMatter.isEmpty == false {
                frontMatter.append("\n")
            }
            
            frontMatter.append(text)
            
        case .content:
            content.append("\n\(text)")
        }
    }
}
