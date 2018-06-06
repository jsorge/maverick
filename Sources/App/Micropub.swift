//
//  Micropub.swift
//  App
//
//  Created by Jared Sorge on 6/5/18.
//

import PathKit
import Vapor

struct MicropubHandler {
    static func routes(_ router: Router) throws {
        router.get("auth") { req -> Response in
            let auth = try req.query.decode(Micropub.Auth.self)
            let servicePath = authedServicesPath + Path(auth.clientID)
            let code: String
            if let serviceData = try? servicePath.read() {
                let decoder = PropertyListDecoder()
                let service = try decoder.decode(Micropub.AuthedService.self, from: serviceData)
                code = service.authCode
            }
            else {
                code = UUID().base64Encoded
                let service = Micropub.AuthedService(clientID: auth.clientID, authCode: code, authToken: nil)
                let encoder = PropertyListEncoder()
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
                let servicePath = authedServicesPath + Path(auth.clientID)
                let data = try servicePath.read()
                let decoder = PropertyListDecoder()
                var service = try decoder.decode(Micropub.AuthedService.self, from: data)
                service.authToken = Micropub.AuthedService.Token.new()
                let encoder = PropertyListEncoder()
                let updatedData = try encoder.encode(service)
                try servicePath.write(updatedData)
                
                let output = Micropub.TokenOutput(accessToken: service.authToken!.value, scope: auth.scope,
                                                  me: auth.me)
                var response = HTTPResponse()
                if let header = req.http.headers.firstValue(name: HTTPHeaderName("Content-Type")), header.contains("json") {
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(output)
                    response.body = HTTPBody(data: jsonData)
                }
                else {
                    let encoder = FormDataEncoder()
                    let formData = try encoder.encode(output, boundary: "MaverickAuthTokenOutput".convertToData())
                    response.body = HTTPBody(data: formData)
                }

                return req.makeResponse(http: response)
            })
        }
        
        
    }
    
    private static var authedServicesPath: Path {
        let path = PathHelper.root + Path("authorizations")
        return path
    }
}

private struct Micropub {
    struct Auth: Codable {
        let me: String
        let redirectURI: String
        let clientID: String
        let scope: String
        
        enum CodingKeys: String, CodingKey {
            case me
            case redirectURI = "redirect_uri"
            case clientID = "client_id"
            case scope
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

extension UUID {
    var base64Encoded: String {
        return String(data: uuidString.data(using: .utf8)!.base64EncodedData(), encoding: .utf8)!
    }
}
