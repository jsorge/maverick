//
//  FileProcessor.swift
//  App
//
//  Created by Jared Sorge on 6/2/18.
//

import Foundation
import SwiftMarkdown

struct FileProcessor {
    static func processMarkdownText(_ markdown: Markdown, for urlPath: String) throws -> String {
        var processedText = markdown
        processedText = relinkImagesInText(processedText, urlPath: urlPath)
        processedText = try markdownToHTML(processedText, options: [.safe])
        return processedText
    }
    
    private static func relinkImagesInText(_ markdown: Markdown, urlPath: String) -> String {
        var output = markdown
        
        // The \ characters have to be escaped, so the pattern is actually:
        // !\[[^\]]*\]\((?<filename>.*?)(?=\"|\))(?<optionalpart>\".*\")?\)
        let pattern = """
        !\\[[^\\]]*\\]\\((?<filename>.*?)(?=\\"|\\))(?<optionalpart>\\".*\\")?\\)
        """
        
        let regex = try! NSRegularExpression.init(pattern: pattern, options: [])
        let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0,
                                                                              length: markdown.count))
        
        for match in matches {
            let range = match.range
            let fullImageMarkdown = NSString(string: markdown).substring(with: range)
            // Formatted like ![](/path/to/image.jpg)
            guard let filepath = fullImageMarkdown.split(separator: "(")
                .last?
                .replacingOccurrences(of: ")", with: ""),
                filepath.contains("http") == false
                else { continue }
            // we should have a link like `assets/image.jpg`
            // it needs to become `/_posts/2018-04-09-hawaii-trip.textbundle/assets/image.jpg`
            let newImagePath = "\(urlPath)/\(filepath)"
            output = output.replacingOccurrences(of: filepath, with: newImagePath)
        }
        
        return output
    }
}
