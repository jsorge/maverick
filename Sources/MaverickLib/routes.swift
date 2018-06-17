import Leaf
import Micropub
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    func fetchPostList(for page: Int, config: SiteConfig) throws -> Page {
        let postList = try PostListController.fetchPostList(forPageNumber: page, config: config)
        let outputPage = Page(style: .list(list: postList), site: config, title: config.title)
        return outputPage
    }

    let config = try SiteConfigController.fetchSite()
    try router.register(collection: MicropubRouteHandler(config: MicropubHelper.makeConfig(fromSite: config)))
    try router.register(collection: StaticPageRouter(siteConfig: config))
    
    // Home
    router.get("") { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        let page = try fetchPostList(for: 1, config: config)
        return leaf.render("index", page)
    }
    
    // Blog posts
    router.get(Int.parameter, Int.parameter, Int.parameter, String.parameter) { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        
        let year = try req.parameters.next(Int.self)
        let month = try req.parameters.next(Int.self)
        let day = try req.parameters.next(Int.self)
        let slug = try req.parameters.next(String.self)
        let path = PostPath(year: year, month: month, day: day, slug: slug)
        
        let postController = PostController(site: config)
        let post = try postController.fetchPost(withPath: path, outputtingFor: .fullText)
        let outputPage = Page(style: .single(post: post), site: config, title: post.title ?? config.title)
        return leaf.render("post", outputPage)
    }
    
    // Archive
    router.get("page", Int.parameter) { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        let page = try req.parameters.next(Int.self)
        let outputPage = try fetchPostList(for: page, config: config)
        return leaf.render("index", outputPage)
    }
}
