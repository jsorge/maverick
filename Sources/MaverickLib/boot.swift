import Routing
import Vapor

/// Called after your application has initialized.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#bootswift)
public func boot(_ app: Application) throws {    
    try PathHelper.prepTheTemporaryPaths()
    runRepeatedTask(app)
}

private func runRepeatedTask(_ app: Application) {
    _ = app.eventLoop.scheduleTask(in: .seconds(10)) { () -> Void in
        do {
            try FeedOutput.makeAllTheFeeds()
            try StaticPageRouter.updateStaticRoutes()
            try FileProcessor.attemptToLinkImagesToPosts(imagePaths: PathHelper.incomingMediaPath.children())
        }
        catch {
            print("Something on the timer went wrong: \(error)")
        }
        
        runRepeatedTask(app)
    }
}
