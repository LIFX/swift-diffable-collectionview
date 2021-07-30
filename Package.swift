// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "swift-diffable-collectionview",
    products: [
        .library(
            name: "Diffable",
            targets: ["Diffable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Diffable",
            dependencies: []),
    ]
)
