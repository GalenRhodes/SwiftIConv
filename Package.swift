// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//@f:0
let package = Package(
    name: "SwiftIConv",
    platforms: [
        .macOS(.v10_15),
        .tvOS(.v13),
        .iOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "SwiftIConv", targets: [ "SwiftIConv", ]),
    ],
    targets: [
        .systemLibrary(name: "iconv"),
        .target(
            name: "SwiftIConv",
            dependencies: [ "iconv" ],
            linkerSettings: [
                .linkedLibrary("iconv", .when( platforms: [ .macOS, .iOS, .tvOS, .watchOS, ])),
                .linkedLibrary("pthread", .when(platforms: [ .linux, .android, .wasi, ])),
            ]
        ),
        .testTarget(name: "SwiftIConvTests", dependencies: [ "SwiftIConv", ]),
    ]
)
//@f:1
