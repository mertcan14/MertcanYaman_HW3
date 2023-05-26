// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DictionaryAPI",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "DictionaryAPI",
            targets: ["DictionaryAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1"))
    ],
    targets: [
        .target(
            name: "DictionaryAPI",
            dependencies: ["Alamofire"])
    ]
)
