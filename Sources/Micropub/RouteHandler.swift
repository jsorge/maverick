//
//  Micropub.swift
//  App
//
//  Created by Jared Sorge on 6/5/18.
//

import Foundation
import PathKit
import Vapor

private let micropubPathComponent = "micropub"
private let mediaPathComponent = "media"

public struct MicropubRouteHandler: RouteCollection {
    private let config: MicropubConfig
    public init(config: MicropubConfig) {
        self.config = config
    }

    public func boot(router: Router) throws {
        router.get("auth") { req -> Response in
            let auth = try req.query.decode(Auth.self)
            let client = self.makeClientFor(clientID: auth.clientID)
            let code: String
            if let serviceData = try? client.servicePath.read() {
                let decoder = JSONDecoder()
                let service = try decoder.decode(Micropub.AuthedService.self, from: serviceData)
                code = service.authCode
            }
            else {
                code = UUID().base64Encoded
                let service = AuthedService(me: self.config.url.absoluteString, clientID: client.id,
                                            authCode: code, scope: auth.scope, authToken: nil)
                let encoder = JSONEncoder()
                let data = try encoder.encode(service)
                try client.servicePath.write(data)
            }

            guard var components = URLComponents(string: auth.redirectURI) else {
                let logger = try req.make(Logger.self)
                logger.info("Error making components from \(auth.redirectURI)")
                return req.makeResponse(http: HTTPResponse())
            }

            var items = components.queryItems ?? []

            let codeItem = URLQueryItem(name: "code", value: code)
            items.append(codeItem)
            let state = URLQueryItem(name: "state", value: auth.state)
            items.append(state)

            components.queryItems = items
            guard let redirect = components.string else { return req.makeResponse(http: HTTPResponse()) }
            return req.redirect(to: redirect)
        }

        router.post("token") { req -> Future<Response> in
            return try req.content.decode(Auth.self).map({ auth -> Response in
                let client = self.makeClientFor(clientID: auth.clientID)

                guard client.servicePath.exists else { throw MicropubError.unknownClient }

                let data = try client.servicePath.read()
                let decoder = JSONDecoder()
                var service = try decoder.decode(Micropub.AuthedService.self, from: data)

                guard let reqCode = auth.authCode, service.authCode == reqCode else {
                    throw MicropubError.invalidAuthCode
                }

                service.authToken = Micropub.AuthedService.Token.new()
                let encoder = JSONEncoder()
                let updatedData = try encoder.encode(service)
                try client.servicePath.write(updatedData)

                let output = Micropub.TokenOutput(accessToken: service.authToken!.value, scope: service.scope,
                                                  me: auth.me)
                var response = HTTPResponse()
                if let header = req.http.headers.firstValue(name: .contentType), header.contains("json") {
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(output)
                    response.body = HTTPBody(data: jsonData)
                }
                else {
                    let formData = output.urlEncodedString.data(using: .utf8)!
                    response.body = HTTPBody(data: formData)
                }

                return req.makeResponse(http: response)
            })
        }

        router.get("micropub") { req -> Response in
            guard AuthHelper.authenticateRequest(req) else {
                let response = HTTPResponse(status: .unauthorized)
                return req.makeResponse(http: response)
            }

            var response = HTTPResponse()
            let item = try req.query.get(String.self, at: ["q"])
            if item == "content" {
                let output = ["media-endpoint": "\(self.config.url.appendingPathComponent("\(micropubPathComponent)/\(mediaPathComponent)"))"]
                let encoder = JSONEncoder()
                let data = try encoder.encode(output)
                response.body = HTTPBody(data: data)
            }

            return req.makeResponse(http: response)
        }

        router.post("micropub") { req -> Future<Response> in
            guard AuthHelper.authenticateRequest(req) else {
                let response = HTTPResponse(status: .unauthorized)
                return Future.map(on: req) {
                    return req.makeResponse(http: response)
                }
            }

            return try req.content.decode(MicropubBlogPostRequest.self).map { postRequest -> Response in
                guard postRequest.h == "entry" else { throw MicropubError.UnsupportedHProperty }
                
                let path = try self.config.newPostHandler(postRequest)
                let location = self.config.url.appendingPathComponent(path)
                
                var response = HTTPResponse(status: .created)
                response.headers.replaceOrAdd(name: "Location", value: location.absoluteString)

                return req.makeResponse(http: response)
            }
        }

        router.post(micropubPathComponent, mediaPathComponent) { req -> Future<Response> in
            guard AuthHelper.authenticateRequest(req) else {
                let response = HTTPResponse(status: .unauthorized)
                return Future.map(on: req) {
                    return req.makeResponse(http: response)
                }
            }
            
            return try req.content.decode(MediaUpload.self).map(to: Response.self, { upload in
                if let location = try self.config.contentReceivedHandler(upload.file) {
                    var response = HTTPResponse(status: .created)
                    let body = ["Location": location]
                    let encoder = JSONEncoder()
                    let bodyData = try encoder.encode(body)
                    response.body = HTTPBody(data: bodyData)
                    return req.makeResponse(http: response)
                }
                return req.makeResponse()
            })
        }
    }

    private func makeClientFor(clientID: String) -> (servicePath: Path, id: String) {
        let encodedClient = clientID.urlEncoded()
        let servicePath = PathHelper.authedServicesPath + Path(encodedClient)
        return (servicePath, encodedClient)
    }
}
