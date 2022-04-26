// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Shared",
    products: [
        .library(name: "Shared", targets: ["Shared"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Shared", dependencies: []),
    ]
)
