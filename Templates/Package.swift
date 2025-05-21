// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "__PROJECT_NAME__",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "__PROJECT_NAME__",
            targets: ["__PROJECT_NAME__"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", exact: "0.8.2")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ]
        ),
        .executableTarget(
            name: "__PROJECT_NAME__",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                .target(name: "Utilities")
            ]
        ),
        .testTarget(
            name: "__PROJECT_NAME__Tests",
            dependencies: ["__PROJECT_NAME__"]
        ),
    ]
)
