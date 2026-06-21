// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "local_notifier",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "local-notifier", targets: ["local_notifier"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "local_notifier",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Classes"
        )
    ]
)
