import Leaf
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let config = try SiteConfigController.fetchSite()
    
    router.get("") { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        let postList = try PostListController.fetchPostList(forPageNumber: 1, config: config)
        let outputPage = Page(style: .list(list: postList), site: config, title: config.title)
        return leaf.render("index", outputPage)
    }
    
    for page in StaticPageController.registeredPages {
        router.get(page) { req -> Future<View> in
            let leaf = try req.make(LeafRenderer.self)
            let post = try StaticPageController.fetchStaticPage(named: page)
            let outputPage = Page(style: .single(post: post), site: config, title: post.title ?? config.title)
            return leaf.render("post", outputPage)
        }
    }
    
    router.get(Int.parameter, Int.parameter, Int.parameter, String.parameter) { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        
        let year = try req.parameters.next(Int.self)
        let month = try req.parameters.next(Int.self)
        let day = try req.parameters.next(Int.self)
        let slug = try req.parameters.next(String.self)
        let path = PostPath(year: year, month: month, day: day, slug: slug)
        
        let post = try PostController.fetchPost(withPath: path)
        let outputPage = Page(style: .single(post: post), site: config, title: post.title ?? config.title)
        return leaf.render("post", outputPage)
    }
    
    router.get("page", Int.parameter) { req -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        let page = try req.parameters.next(Int.self)
        let postList = try PostListController.fetchPostList(forPageNumber: page, config: config)
        let outputPage = Page(style: .list(list: postList), site: config, title: config.title)
        return leaf.render("index", outputPage)
    }
}
