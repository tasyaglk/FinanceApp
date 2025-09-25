// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LottieAnimation",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "LottieAnimation",
            type: .static,
            targets: ["LottieAnimation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git",
                 from: "4.5.2")
    ],
    targets: [
        .target(
            name: "LottieAnimation",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ],
        )
    ]
)
