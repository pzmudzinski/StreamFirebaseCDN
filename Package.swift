// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "stream-firebase-cdn",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StreamFirebaseCDN",
            targets: ["StreamFirebaseCDN"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.4.0")
        ),
        .package(
            url: "https://github.com/getstream/stream-chat-swift",
            .upToNextMajor(from: "4.41.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StreamFirebaseCDN",
            dependencies: [
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "StreamChat", package: "stream-chat-swift")
            ]
        ),
        .testTarget(
            name: "StreamFirebaseCDNTests",
            dependencies: ["StreamFirebaseCDN"]
        )
    ]
)
