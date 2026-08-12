// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyStaticSite",
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "MyStaticSite",
            dependencies: [
                .product(name: "WingedSwift", package: "Winged-Swift")
            ],
            path: "Sources"
        )
    ]
)

