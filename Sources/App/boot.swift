import Routing
import Vapor

/// Called after your application has initialized.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#bootswift)
public func boot(_ app: Application) throws {
    runRepeatedTask(app)
}

private func runRepeatedTask(_ app: Application) {
    _ = app.eventLoop.scheduleTask(in: .seconds(10)) { () -> Void in
        do {
            try FeedOutput.makeAllTheFeeds()
        }
        catch {
            print("Unable to make all the feeds")
        }
        
        runRepeatedTask(app)
    }
}
