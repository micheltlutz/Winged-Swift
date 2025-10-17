// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WingedSwift",
    products: [
        .library(
            name: "WingedSwift",
            targets: ["WingedSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "WingedSwift"),
        .testTarget(
            name: "WingedSwiftTests",
            dependencies: ["WingedSwift"]
        )
    ]
)
