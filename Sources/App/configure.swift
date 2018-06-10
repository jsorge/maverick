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
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    try services.register(MaverickLeafProvider())

    var middleware = MiddlewareConfig.default()
    middleware.use(FileMiddleware.self)
    services.register(middleware)
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
            return try LeafConfig(
                tags: container.make(),
                viewsDir: dir.workDir + "Public/Views",
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

