import Foundation
import PathKit
import Vapor

struct AuthHelper {
    static func authenticateRequest(_ req: Request) -> Bool {
        let tokens = fetchAllAuthTokens()
        if let authHeader = req.headers.first(name: .authorization) {
            let split = authHeader.split(separator: " ")
            guard let token = split.last else { return false }
            return tokens.contains(String(token))
        }
        else {
            guard let auth = try? req.content.decode(PostBodyAuth.self) else { return false }
            return tokens.contains(auth.accessToken)
        }
    }
    
    static private func fetchAllAuthTokens() -> [String] {
        guard let authedServices = try? PathHelper.authedServicesPath.children() else { return [] }
        var tokens = [String]()
        let decoder = JSONDecoder()
        for service in authedServices {
            do {
                let serviceData = try service.read()
                let service = try decoder.decode(AuthedService.self, from: serviceData)
                guard let token = service.authToken else { continue }
                tokens.append(token.value)
            }
            catch {
                continue
            }
        }

        return tokens
    }
}

/// A request that contains the access token in its body
private struct PostBodyAuth: Codable {
    let accessToken: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
