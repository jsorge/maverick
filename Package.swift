// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "Maverick",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/jsorge/vapor.git", .branch("master")),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/markdown.git", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/jsorge/textbundleify.git", .branch("master")),
    ],
    targets: [
    	.target(name: "Micropub", dependencies: ["PathKit", "Vapor"]),
        .target(name: "MaverickLib", dependencies: ["Leaf",
                                            "Micropub",
                                            "SwiftMarkdown",
                                            "TextBundleify",
                                            "PathKit",
                                            "Vapor",
                                            "Yams"]),
        .target(name: "Maverick", dependencies: ["MaverickLib"]),
        .testTarget(name: "AppTests", dependencies: ["MaverickLib"]),
    ]
)
