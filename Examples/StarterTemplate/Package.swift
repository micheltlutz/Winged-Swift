// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyStaticSite",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "MyStaticSite",
            dependencies: ["WingedSwift"],
            path: "Sources"
        )
    ]
)

