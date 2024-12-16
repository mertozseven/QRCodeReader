// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QRCodeReader",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "QRCodeReader",
            targets: ["QRCodeReader"])
    ],
    targets: [
        .target(
            name: "QRCodeReader",
            path: "Sources/QRCodeReader")
    ]
)
