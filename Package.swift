// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedbackSwift",
    defaultLocalization: "en",
    platforms: [.iOS(.v11), .macCatalyst(.v13)],
    products: [
        .library(name: "FeedbackSwift", targets: ["FeedbackSwift"])
    ],
    targets: [
        .target(
            name: "FeedbackSwift",
            resources: [
                .copy("Resources/PlatformNames.plist")
            ]
        ),
        .testTarget(name: "FeedbackSwiftTests", dependencies: ["FeedbackSwift"])
    ]
)
