// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MiBandProtocol",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "MiBandProtocol", targets: ["MiBandProtocol"]),
    ],
    targets: [
        .target(name: "MiBandProtocol"),
        .testTarget(name: "MiBandProtocolTests", dependencies: ["MiBandProtocol"]),
    ]
)
