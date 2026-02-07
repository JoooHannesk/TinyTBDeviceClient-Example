// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinyTBDeviceClient-Example",
    platforms: [
        .macOS(.v13),
        .iOS(.v17),
        .custom("Linux", versionString: "6.12.34")
    ],
    dependencies: [
        .package(url: "https://github.com/JoooHannesk/TinyTBDeviceClient.git", from: "0.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "TinyTBDeviceClient-Example",
            dependencies: [
                .product(name: "TinyTBDeviceClient", package: "TinyTBDeviceClient"),
            ],
        ),
    ]
)
