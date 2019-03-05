import Core
import Leaf
import Service
import TemplateKit
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter(caseInsensitive: true)
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    try services.register(MaverickLeafProvider())

    var middleware = MiddlewareConfig.default()
    
    let files: FileMiddleware
    if isDebug() {
        files = FileMiddleware(publicDirectory: "\(DirectoryConfig.detect().workDir)/_dev/Public")
    }
    else {
        files = FileMiddleware(publicDirectory: "\(DirectoryConfig.detect().workDir)/Public")
    }
    middleware.use(files)
    
    services.register(middleware)

    SiteContentChangeResponderManager.shared.registerResponder(SitePinger())
}

private final class MaverickLeafProvider: Provider {
    /// See Service.Provider.repositoryName
    public static let repositoryName = "leaf"
    
    public init() {}
    
    /// See Service.Provider.Register
    public func register(_ services: inout Services) throws {
        services.register([TemplateRenderer.self, ViewRenderer.self]) { container -> LeafRenderer in
            let config = try container.make(LeafConfig.self)
            return LeafRenderer(
                config: config,
                using: container
            )
        }
        
        services.register { container -> LeafConfig in
            let dir = try container.make(DirectoryConfig.self)
            let viewsDir: String
            if isDebug() {
                viewsDir = dir.workDir + "_dev/Resources/Views"
            }
            else {
                viewsDir = dir.workDir + "Resources/Views"
            }
            
            return try LeafConfig(
                tags: container.make(),
                viewsDir: viewsDir,
                shouldCache: container.environment != .development
            )
        }
        
        services.register { container -> LeafTagConfig in
            return LeafTagConfig.default()
        }
    }
    
    /// See Service.Provider.boot
    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}

