//
//  AdminController.swift
//  MaverickLib
//
//  Created by Jared Sorge on 7/15/19.
//

import Foundation
import ShellOut
import Vapor

struct AdminRouteCollection: RouteCollection {
    func boot(router: Router) throws {
        let adminRouter = router.grouped("_admin")

        adminRouter.get("reload") { req -> Future<Response> in
            return Future.map(on: req, {
                if AdminController.reloadActionTriggered() {
                    return req.response(http: HTTPResponse(status: .ok))
                }
                else {
                    return req.response(http: HTTPResponse(status: .internalServerError))
                }
            })
        }
    }
}

struct AdminController {
    static func reloadActionTriggered() -> Bool {
        do {
            let workDir = DirectoryConfig.detect().workDir
            try shellOut(to: .gitPull(remote: "origin", branch: "master"), at: workDir)
            return true
        }
        catch {
            print("git error: \(error)")
            return false
        }
    }
}
