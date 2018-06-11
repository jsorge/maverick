//
//  Extensions.swift
//  App
//
//  Created by Jared Sorge on 6/11/18.
//

import Foundation
import Vapor

extension UUID {
    var base64Encoded: String {
        return String(data: uuidString.data(using: .utf8)!.base64EncodedData(), encoding: .utf8)!
    }
}

extension HTTPHeaderName {
    static var authorization = HTTPHeaderName("Authorization")
}
