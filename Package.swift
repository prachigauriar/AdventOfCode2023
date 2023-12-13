// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription


let package = Package(
    name: "AdventOfCode2023",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "CommandLine",
            targets: ["CommandLine"]
        ),
        .executable(
            name: "AdventOfCode2023",
            targets: ["AdventOfCode2023"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode2023",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                "CommandLine",
            ]
        ),
        .macro(
            name: "CommandLineMacros",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "CommandLine",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "CommandLineMacros",
            ]
        ),
    ]
)
