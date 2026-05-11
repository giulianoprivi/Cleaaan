// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Cleaaan",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "CleaaanCore",
            path: "Sources/CleaaanCore"
        ),
        .executableTarget(
            name: "Cleaaan",
            dependencies: ["CleaaanCore"],
            path: "Sources/Cleaaan"
        ),
        .testTarget(
            name: "CleaaanTests",
            dependencies: ["CleaaanCore"],
            path: "Tests/CleaaanTests"
        )
    ]
)
