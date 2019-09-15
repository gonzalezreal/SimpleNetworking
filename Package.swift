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
    dependencies: [],
    targets: [
        .target(
            name: "SimpleNetworking",
            dependencies: []
        ),
        .testTarget(
            name: "SimpleNetworkingTests",
            dependencies: ["SimpleNetworking"]
        ),
    ]
)
