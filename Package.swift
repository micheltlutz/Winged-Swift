// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WingedSwift",
    products: [
        .library(
            name: "WingedSwift",
            targets: ["WingedSwift"]),
    ],
    targets: [
        .target(
            name: "WingedSwift"),
        .testTarget(
            name: "WingedSwiftTests",
            dependencies: ["WingedSwift"]
        ),
    ]
)
