// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CatsKit",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "CatsKitService",
            targets: ["CatsKitService"]),
        .library(
            name: "CatsKitServiceStaging",
            targets: ["CatsKitServiceStaging"]),
        .library(
            name: "CatsKitDomain",
            targets: ["CatsKitDomain"]),
        .library(
            name: "CatsKitDomainStaging",
            targets: ["CatsKitDomainStaging"])
    ],
    dependencies: [
        .package(name: "HTTPNetworkService", path: "../HTTPNetworkService")
    ],
    targets: [
        .target(
            name: "CatsKitDomain",
            dependencies: []
        ),
        .target(
            name: "CatsKitDomainStaging",
            dependencies: ["CatsKitDomain"]
        ),
        .target(
            name: "CatsKitService",
            dependencies: [
                "CatsKitDomain",
                .product(name: "HTTPNetworkService", package: "HTTPNetworkService")
            ]
        ),
        .target(
            name: "CatsKitServiceStaging",
            dependencies: ["CatsKitService", "CatsKitDomainStaging",
                           .product(name: "HTTPNetworkServiceStaging", package: "HTTPNetworkService")],
            resources: [.process("Resources/")]
        ),
        .testTarget(
            name: "CatsKitDomainTests",
            dependencies: ["CatsKitDomain", "CatsKitDomainStaging"]
        ),
        .testTarget(
            name: "CatsKitServiceTests",
            dependencies: ["CatsKitService", "CatsKitServiceStaging", "CatsKitDomain", "CatsKitDomainStaging"]
        )
    ]
)
