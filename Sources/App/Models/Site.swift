//
//  PageContext.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

/// Data about the whole site
struct Site: Codable {
    /// Goes in the meta-title tag in the site header
    let metaTitle: String
    /// The title that goes in the header on the page (i.e. "jsorge.net" or "Inessential")
    let title: String
    /// The description that goes below the title in the header.
    /// (i.e. "Christian, husbend, dad, developer, batman afficianado")
    let description: String
    /// The base URL of the site
    let url: URL
    /// The year to go in the footer
    let year: String
}
