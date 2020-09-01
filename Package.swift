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
            name: "LEDUtils",
            targets: ["LEDUtils"]),
        .library(
            name: "LinuxI2CDev",
            targets: ["LinuxI2CDev"]),
        .library(
            name: "LinuxI2C",
            targets: ["LinuxI2C"]),
        .library(
            name: "LinuxSPIDev",
            targets: ["LinuxSPIDev"]),
        .library(
            name: "LinuxSPI",
            targets: ["LinuxSPI"]),
        .library(
            name: "MCP9808",
            targets: ["MCP9808"]),
        .library(
            name: "PCA9685",
            targets: ["PCA9685"]),
        .library(
            name: "ShiftLED",
            targets: ["ShiftLED"]),
        .library(
            name: "TEA5767",
            targets: ["TEA5767"]),
        .executable(
            name: "DeftExample",
            targets: ["DeftExample"]),
        .executable(
            name: "SimpleExample",
            targets: ["SimpleExample"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/didactek/deft-layout.git", from: "0.0.1"),
        // For FTDI SPI support on Mac:
        .package(url: "https://github.com/didactek/ftdi-synchronous-serial.git", from: "0.0.4"),
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
            name: "LEDUtils",
            dependencies: []),
        .systemLibrary(
            name: "LinuxI2CDev"),
        .target(
            name: "LinuxI2C",
            dependencies: ["DeftBus", "LinuxI2CDev"]),
        .systemLibrary(
            name: "LinuxSPIDev"),
        .target(
            name: "LinuxSPI",
            dependencies: ["DeftBus", "LinuxSPIDev"]),
        .target(
            name: "MCP9808",
            dependencies: ["DeftBus", "DeftLayout"]),
        .testTarget(
            name: "MCP9808Tests",
            dependencies: ["DeftBus", "DeftLayout", "MCP9808"]),
        .target(
            name: "PCA9685",
            dependencies: ["DeftBus", "DeftLayout"]),
        .target(
            name: "ShiftLED",
            dependencies: ["DeftBus", "LEDUtils"]),
        .testTarget(
            name: "ShiftLEDTests",
            dependencies: ["LEDUtils", "LinuxSPI", "ShiftLED"]),
        .target(
            name: "TEA5767",
            dependencies: ["DeftBus", "DeftLayout"]),
//        .testTarget(
//            name: "TEA5767Tests",
//            dependencies: ["DeftLayout", "DeftBus", "TEA5767"]),
        .target(
            name: "DeftExample",
            dependencies: ["DeftBus", "DeftLayout", "LEDUtils", "LinuxI2C", "LinuxSPI", "MCP9808", "PCA9685", "ShiftLED", "TEA5767", "FTDI"]),  // LibUSB for FTDI-SPI/Mac
        .target(
            name: "SimpleExample",
            dependencies: ["DeftBus", "DeftLayout", "LEDUtils", "LinuxI2C", "LinuxSPI", "MCP9808", "PCA9685", "ShiftLED", "TEA5767", "FTDI"]),  // LibUSB for FTDI-SPI/Mac
    ]
)
