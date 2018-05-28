import Leaf
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get("") { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        let context = [String: String]()
        return leaf.render("home", context)
    }
}
