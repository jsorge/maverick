// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Maverick",
    products: [
        .library(name: "MaverickModels", targets: ["MaverickModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.2.2"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/markdown.git", from: "0.4.0"),
        .package(url: "https://github.com/jsorge/textbundleify.git", .branch("master")),
    ],
    targets: [
    	.target(name: "Micropub", dependencies: ["PathKit", "Vapor"]),
        .target(name: "MaverickLib", dependencies: ["Leaf",
                                            "MaverickModels",
                                            "Micropub",
                                            "SwiftMarkdown",
                                            "TextBundleify",
                                            "PathKit",
                                            "Vapor",
                                            "Yams"]),
        .target(name: "Maverick", dependencies: ["MaverickLib"]),
        .target(name: "MaverickModels", dependencies: ["PathKit"]),
        .testTarget(name: "MaverickLibTests", dependencies: [
        	"MaverickLib",
        	"PathKit",
        	"TextBundleify",
        ]),
    ]
)
