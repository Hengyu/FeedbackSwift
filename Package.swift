// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedbackSwift",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macCatalyst(.v17), .macOS(.v14), .tvOS(.v17), .visionOS(.v1)],
    products: [
        .library(name: "FeedbackSwift", targets: ["FeedbackSwift"])
    ],
    targets: [
        .target(
            name: "FeedbackSwift",
            resources: [
                .copy("Resources/PlatformNames.plist"),
                .process("Resources/localizable.xcstrings")
            ]
        ),
        .testTarget(name: "FeedbackSwiftTests", dependencies: ["FeedbackSwift"]),
    ]
)
