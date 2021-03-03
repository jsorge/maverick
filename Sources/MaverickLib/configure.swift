import Leaf
import LeafKit
import Logging
import Vapor

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    // Register routes to the router
    try registerRoutes(app)

    // Configure the rest of your application here
    app.leaf.configuration = MaverickLeafProvider.config
    app.views.use(.leaf)
    
    let files: FileMiddleware
    let workingDir = DirectoryConfiguration.detect().workingDirectory
    if isDebug() {
        files = FileMiddleware(publicDirectory: "\(workingDir)/_dev/Public")
    }
    else {
        files = FileMiddleware(publicDirectory: "\(workingDir)/Public")
    }
    app.middleware.use(files)

    SiteContentChangeResponderManager.shared.registerResponder(SitePinger())

    try PathHelper.prepTheTemporaryPaths()
    MaverickLogger.shared = app.logger
    runRepeatedTask(app)
}

private enum MaverickLeafProvider {
    static var config: LeafConfiguration {
        let workingDir = DirectoryConfiguration.detect().workingDirectory
        let viewsDir: String
        if isDebug() {
            viewsDir = workingDir + "_dev/Resources/Views"
        }
        else {
            viewsDir = workingDir + "Resources/Views"
        }

        let configuration = LeafConfiguration(
            rootDirectory: viewsDir
        )

        return configuration
    }
}

private func runRepeatedTask(_ app: Application) {
    _ = app.eventLoopGroup.next().scheduleTask(in: .seconds(10)) {
        do {
            try FeedOutput.makeAllTheFeeds()
            try StaticPageRouter.updateStaticRoutes()
            try FileProcessor.attemptToLinkImagesToPosts(imagePaths: PathHelper.incomingMediaPath.children())
        }
        catch {
            MaverickLogger.shared?.error("Something on the timer went wrong: \(error)")
        }

        runRepeatedTask(app)
    }
}

