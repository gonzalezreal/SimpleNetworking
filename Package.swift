// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SimpleNetworking",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3),
    ],
    products: [
        .library(name: "SimpleNetworking", targets: ["SimpleNetworking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.2.0"),
    ],
    targets: [
        .target(name: "SimpleNetworking", dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "SimpleNetworkingTests", dependencies: ["SimpleNetworking"]),
    ]
)
