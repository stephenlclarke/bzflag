// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "BZFlag",
  platforms: [.macOS(.v14)],
  products: [
    .executable(name: "BZFlagApp", targets: ["BZFlagApp"])
  ],
  targets: [
    .target(name: "BZFlagCore"),
    .executableTarget(name: "BZFlagApp", dependencies: ["BZFlagCore"]),
    .testTarget(name: "BZFlagCoreTests", dependencies: ["BZFlagCore"])
  ]
)
