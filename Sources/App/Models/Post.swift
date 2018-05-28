//
//  Post.swift
//  App
//
//  Created by Jared Sorge on 5/28/18.
//

import Foundation

struct Post: Codable {
    let date: Date
    let formattedDate: String
    let url: String
    let title: String
    let content: String
}
