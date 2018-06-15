import Foundation
import Vapor

public struct XMLRPCRouteHandler: RouteCollection {
    public func boot(router: Router) throws {
        router.get("xmlrpc.php") { req -> Response in
            return req.makeResponse()
        }
    }
}
