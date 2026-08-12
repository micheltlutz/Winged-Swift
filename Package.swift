// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WingedSwift",
    products: [
        .library(
            name: "WingedSwift",
            targets: ["WingedSwift"]),
        .executable(
            name: "winged",
            targets: ["WingedCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "WingedSwift",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .executableTarget(
            name: "WingedCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [.copy("Templates")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "WingedSwiftTests",
            dependencies: ["WingedSwift"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
