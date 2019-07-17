import Leaf
import MaverickModels
import Micropub
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let config = try SiteConfigController.fetchSite()
    try router.register(collection: MicropubRouteHandler(config: MicropubHelper.makeConfig(fromSite: config)))
    try router.register(collection: StaticPageRouter(siteConfig: config))
    try router.register(collection: PostListRouteCollection(config: config))
    try router.register(collection: SinglePostRouteCollection(config: config))
    try router.register(collection: TagController())
    try router.register(collection: AdminRouteCollection())
}
