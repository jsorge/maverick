//
//  Micropub.swift
//  App
//
//  Created by Jared Sorge on 6/5/18.
//

import Foundation
import PathKit
import Vapor

enum MicropubError: String, Error {
    case invalidClient
    case unknownClient
    case invalidAuthCode
    case authenticationFailed
    case UnsupportedHProperty
}

extension MicropubError: Debuggable {
    var identifier: String {
        return rawValue
    }

    var reason: String {
        return rawValue
    }
}

struct MicropubHandler: RouteCollection {
    private let config: SiteConfig
    init(siteConfig config: SiteConfig) {
        self.config = config
    }
    
    func boot(router: Router) throws {
        router.get("auth") { req -> Response in
            let auth = try req.query.decode(Micropub.Auth.self)
            guard let clientID = URLComponents(string: auth.clientID)?.host
                else { throw MicropubError.invalidClient }
            let servicePath = self.authedServicesPath + Path(clientID)
            let code: String
            if let serviceData = try? servicePath.read() {
                let decoder = JSONDecoder()
                let service = try decoder.decode(Micropub.AuthedService.self, from: serviceData)
                code = service.authCode
            }
            else {
                code = UUID().base64Encoded
                let service = Micropub.AuthedService(clientID: clientID, authCode: code, authToken: nil)
                let encoder = JSONEncoder()
                let data = try encoder.encode(service)
                try servicePath.write(data)
            }
            
            guard var components = URLComponents(string: auth.redirectURI) else {
                return req.makeResponse(http: HTTPResponse())
            }
            let codeQuery = URLQueryItem(name: "code", value: code)
            components.queryItems = [codeQuery]
            
            guard let redirect = components.string else { return req.makeResponse(http: HTTPResponse()) }
            return req.redirect(to: redirect)
        }
        
        router.post("token") { req -> Future<Response> in
            return try req.content.decode(Micropub.Auth.self).map({ auth -> Response in
                let servicePath = self.authedServicesPath + Path(auth.clientID)

                guard servicePath.exists else { throw MicropubError.unknownClient }

                let data = try servicePath.read()
                let decoder = JSONDecoder()
                var service = try decoder.decode(Micropub.AuthedService.self, from: data)

                guard let reqCode = auth.authCode, service.authCode == reqCode else {
                    throw MicropubError.invalidAuthCode
                }

                service.authToken = Micropub.AuthedService.Token.new()
                let encoder = JSONEncoder()
                let updatedData = try encoder.encode(service)
                try servicePath.write(updatedData)
                
                let output = Micropub.TokenOutput(accessToken: service.authToken!.value, scope: auth.scope,
                                                  me: auth.me)
                var response = HTTPResponse()
                if let header = req.http.headers.firstValue(name: HTTPHeaderName("Content-Type")),
                    header.contains("json")
                {
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(output)
                    response.body = HTTPBody(data: jsonData)
                }
                else {
                    let encoder = FormDataEncoder()
                    let formData = try encoder.encode(output,
                                                      boundary: "MaverickAuthTokenOutput".convertToData())
                    response.body = HTTPBody(data: formData)
                }

                return req.makeResponse(http: response)
            })
        }

        router.get("micropub") { req -> Response in
            guard self.authenticateRequest(req) else { throw MicropubError.authenticationFailed }

            var response = HTTPResponse()
            let item = try req.query.get(String.self, at: ["q"])
            if item == "content" {
                let output = ["media-endpoint": "\(self.config.url.appendingPathComponent("micropub/media"))"]
                let encoder = JSONEncoder()
                let data = try encoder.encode(output)
                    response.body = HTTPBody(data: data)
            }

            return req.makeResponse(http: response)
        }

        router.post("micropub") { req -> Future<Response> in
            return try req.content.decode(MicropubBlogPostRequest.self).map { postRequest -> Response in
                guard self.authenticateRequest(req) else { throw MicropubError.authenticationFailed }
                guard postRequest.h == "entry" else { throw MicropubError.UnsupportedHProperty }
                try PostConverter.saveMicropubPost(postRequest)
                return req.makeResponse()
            }
        }

        router.post("micropub", "media") { req -> Response in
            return req.makeResponse()
        }
    }
    
    private var authedServicesPath: Path {
        let path = PathHelper.root + Path("authorizations")
        if path.exists == false {
            try? path.mkpath()
        }
        return path
    }

    private func authenticateRequest(_ req: Request) -> Bool {
        func fetchAllAuthTokens() -> [String] {
            guard let authedServices = try? authedServicesPath.children() else { return [] }
            var tokens = [String]()
            let decoder = JSONDecoder()
            for service in authedServices {
                do {
                    let serviceData = try service.read()
                    let service = try decoder.decode(Micropub.AuthedService.self, from: serviceData)
                    guard let token = service.authToken else { continue }
                    tokens.append(token.value)
                }
                catch {
                    continue
                }
            }

            return tokens
        }

        let tokens = fetchAllAuthTokens()
        if let authHeader = req.http.headers.firstValue(name: .authorization) {
            let split = authHeader.split(separator: " ")
            guard let token = split.last else { return false }
            return tokens.contains(String(token))
        }
        else {
            // TODO: fetch `access_token` from the body
        }

        return false
    }
}

struct MicropubBlogPostRequest: Codable {
    let h: String
    let name: String?
    let content: String
    let date = Date()
}

private struct Micropub {
    struct Auth: Codable {
        let me: String
        let redirectURI: String
        let clientID: String
        let scope: String
        let authCode: String?
        
        enum CodingKeys: String, CodingKey {
            case me
            case redirectURI = "redirect_uri"
            case clientID = "client_id"
            case scope
            case authCode = "code"
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
        
        let clientID: String
        let authCode: String
        var authToken: Token?
    }
    
    struct TokenOutput: Codable {
        let accessToken: String
        let scope: String?
        let me: String
    }
}

private extension UUID {
    var base64Encoded: String {
        return String(data: uuidString.data(using: .utf8)!.base64EncodedData(), encoding: .utf8)!
    }
}

private extension HTTPHeaderName {
    static var authorization = HTTPHeaderName("Authorization")
}
