// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AccessibilityMCP",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "accessibility-mcp",
            targets: ["AccessibilityMCP"]
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
            name: "AccessibilityMCP",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AccessibilityMCPTests",
            dependencies: ["AccessibilityMCP"]
        )
    ]
)
