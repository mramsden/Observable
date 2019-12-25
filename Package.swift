// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Observable",
    products: [
        .library(
            name: "Observable",
            targets: ["Observable"]),
    ],
    targets: [
        .target(
            name: "Observable",
            dependencies: []),
        .testTarget(
            name: "ObservableTests",
            dependencies: ["Observable"]),
    ]
)
