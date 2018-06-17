//
//  Output.swift
//  App
//
//  Created by Jared Sorge on 6/4/18.
//

import Foundation

enum TextOutputType {
    case fullText
    case microblog
    
    static var all: [TextOutputType] {
        return [.fullText, .microblog]
    }
}
