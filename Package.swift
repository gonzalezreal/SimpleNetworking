// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SimpleNetworking",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "SimpleNetworking",
            targets: ["SimpleNetworking"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.2.0"),
    ],
    targets: [
        .target(name: "SimpleNetworking", dependencies: ["Logging"]),
        .testTarget(name: "SimpleNetworkingTests", dependencies: ["SimpleNetworking"]),
    ]
)
