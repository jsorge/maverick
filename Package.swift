// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Maverick",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.2"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/markdown.git", .upToNextMajor(from: "0.4.0")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "SwiftMarkdown", "PathKit", "Yams"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
