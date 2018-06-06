//
//  PageContext.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

/// Data about the whole site
struct SiteConfig: Codable {
    /// Goes in the `meta name=description` tag.
    let metaDescription: String
    /// The title that goes in the header on the page (i.e. "jsorge.net" or "Inessential").
    let title: String
    /// The description that goes below the title in the header.
    /// (i.e. "Christian, husbend, dad, developer, batman afficianado")
    let description: String
    /// The base URL of the site.
    let url: URL
    /// The number of posts to include when listing posts
    let batchSize: Int
    /// The year to go in the footer.
    let year: String = {
        let calendar = Calendar.current
        let date = Date()
        return "\(calendar.component(.year, from: date))"
    }()
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metaDescription, forKey: .metaDescription)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode("\(url)", forKey: .url)
        try container.encode(batchSize, forKey: .batchSize)
        try container.encode(year, forKey: .year)
    }
    
    private enum CodingKeys: String, CodingKey {
        case metaDescription
        case title
        case description
        case url
        case batchSize
        case year
    }
}
