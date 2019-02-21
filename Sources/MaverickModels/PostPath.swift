//
//  PostPath.swift
//  App
//
//  Created by Jared Sorge on 6/1/18.
//

import Foundation
import PathKit

public struct PostPath: Codable, Comparable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let slug: String
    
    public var asURIPath: String {
        return "/\(year)/\(String(format: "%02d", month))/\(String(format: "%02d", day))/\(slug)"
    }
    
    public var asFilename: String {
        return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))-\(slug)"
    }
    
    public init(year: Int, month: Int, day: Int, slug: String) {
        self.year = year
        self.month = month
        self.day = day
        self.slug = slug
    }
    
    public init?(path: Path) {
        // ignore hidden files
        guard path.lastComponent.starts(with: ".") == false else { return nil }
        
        var components = path.lastComponentWithoutExtension.split(separator: "-")
        // ensure that the file name was formatted correctly for a post
        guard components.count > 3 else { return nil }

        let _day = components[2]
        let _month = components[1]
        let _year = components[0]
        let slug = components.dropFirst(3).joined(separator: "-")
        
        guard let day = Int(_day), let month = Int(_month), let year = Int(_year) else { return nil }
        
        self.year = year
        self.month = month
        self.day = day
        self.slug = String(slug)
    }
    
    public static func < (lhs: PostPath, rhs: PostPath) -> Bool {
        if lhs.year < rhs.year {
            return true
        }
        
        if lhs.month < rhs.month {
            return true
        }
        
        if lhs.day < rhs.day {
            return true
        }
        
        return false
    }
    
    private enum CodingKeys: String, CodingKey {
        case year
        case month
        case day
        case slug
    }
}
