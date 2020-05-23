// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Deft",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DeftBus",
            targets: ["DeftBus"]),
        .library(
            name: "DeftLayout",
            targets: ["DeftLayout"]),
        .library(
            name: "MCP9808",
            targets: ["MCP9808"]),
        .library(
            name: "TEA5767",
            targets: ["TEA5767"]),
        .executable(
            name: "DeftExample",
            targets: ["DeftExample"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DeftBus",
            dependencies: []),
        .testTarget(
            name: "DeftBusTests",
            dependencies: ["DeftBus", "DeftLayout"]),
        .target(
            name: "DeftLayout",
            dependencies: []),
        .testTarget(
            name: "DeftLayoutTests",
            dependencies: ["DeftLayout"]),
        .target(
            name: "MCP9808",
            dependencies: ["DeftBus", "DeftLayout"]),
        .testTarget(
            name: "MCP9808Tests",
            dependencies: ["DeftBus", "DeftLayout", "MCP9808"]),
        .target(
            name: "TEA5767",
            dependencies: ["DeftBus", "DeftLayout"]),
//        .testTarget(
//            name: "TEA5767Tests",
//            dependencies: ["DeftLayout", "DeftBus", "TEA5767"]),
        .target(
            name: "DeftExample",
            dependencies: ["DeftBus", "DeftLayout", "MCP9808", "TEA5767"]),
    ]
)
