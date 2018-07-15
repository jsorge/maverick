import PathKit

struct PathHelper {
    static var root: Path {
        return Path(DirectoryConfig.detect().workDir)
    }
    
    static var authedServicesPath: Path {
        let path = PathHelper.root + Path("authorizations")
        if path.exists == false {
            try? path.mkpath()
        }
        return path
    }
}
