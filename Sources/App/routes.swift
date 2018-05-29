import Leaf
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let config = try SiteConfigController.fetchSite()
    
    //    router.get("") { req -> Future<View> in
    //        let leaf = try req.make(LeafRenderer.self)
    //        let context = [String: String]()
    //        return leaf.render("home", context)
    //    }
    
    // static page
    for page in StaticPageController.registeredPages {
        router.get(page) { req -> Future<View> in
            let leaf = try req.make(LeafRenderer.self)
            let post = try StaticPageController.fetchStaticPage(named: page)
            let outputPage = Page(style: .single(post: post), site: config, title: post.title ?? config.title)
            return leaf.render("post", outputPage)
        }
    }
    
    // blog post
    
    // archive
//    router.get("page", Int.parameter) { req -> Future<View> in
//
//    }
}
