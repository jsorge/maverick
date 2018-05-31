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
    var year: String {
        let calendar = Calendar.current
        let date = Date()
        return "\(calendar.component(.year, from: date))"
    }
}