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
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "SimpleNetworking", dependencies: []),
        .testTarget(name: "SimpleNetworkingTests", dependencies: ["SimpleNetworking"]),
    ]
)
