//
//  Models.swift
//  App
//
//  Created by Jared Sorge on 6/11/18.
//

import Foundation
import Vapor

public struct MicropubBlogPostRequest: Codable {
    public let h: String
    public let name: String?
    public let content: String
    public let date = Date()
    public let photo: File?
}

struct MediaUpload: Content {
    let file: File?
}

struct Auth: Codable {
    let me: String
    let redirectURI: String
    let clientID: String
    let scope: String
    let authCode: String?
    let state: String?

    enum CodingKeys: String, CodingKey {
        case me
        case redirectURI = "redirect_uri"
        case clientID = "client_id"
        case scope
        case authCode = "code"
        case state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.me = try container.decode(String.self, forKey: .me)
        self.redirectURI = try container.decode(String.self, forKey: .redirectURI)
        self.clientID = try container.decode(String.self, forKey: .clientID)
        self.scope = try container.decode(String.self, forKey: .scope)
        self.authCode = try container.decodeIfPresent(String.self, forKey: .authCode)
        
        var state: String? = nil
        if let stateStr = try container.decodeIfPresent(String.self, forKey: .state) {
            state = stateStr
        }
        else if let stateInt = try container.decodeIfPresent(Int.self, forKey: .state) {
            state = "\(stateInt)"
        }
        self.state = state
    }
}

struct AuthedService: Codable {
    struct Token: Codable {
        let value: String
        let date: Date

        static func new() -> Token {
            return Token(value: UUID().base64Encoded, date: Date())
        }
    }

    let me: String
    let clientID: String
    let authCode: String
    var authToken: Token?
}

struct TokenOutput: Codable {
    let accessToken: String
    let scope: String?
    let me: String
}
