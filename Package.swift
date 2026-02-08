// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AxMCP",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "axmcp",
            targets: ["AxMCP"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/modelcontextprotocol/swift-sdk",
            from: "0.1.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "AxMCP",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AxMCPTests",
            dependencies: ["AxMCP"]
        )
    ]
)
