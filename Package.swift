// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SCNPath",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "SCNPath",
      targets: ["SCNPath"])
  ],
  targets: [
    // No tests created just yet.
    .target(name: "SCNPath"),
    .testTarget(
      name: "SCNPathTests",
      dependencies: ["SCNPath"])
  ],
  swiftLanguageVersions: [.v5]
)
