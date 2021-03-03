import PathKit
import Vapor

struct PathHelper {
    static var root: Path {
        return Path(DirectoryConfiguration.detect().workingDirectory)
    }
    
    static var authedServicesPath: Path {
        let path = PathHelper.root + Path("authorizations")
        if path.exists == false {
            try? path.mkpath()
        }
        return path
    }
}
