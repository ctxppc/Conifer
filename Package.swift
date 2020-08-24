// swift-tools-version:5.3

// Conifer © 2019–2020 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Conifer",
	platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7)],
	products: [
		.library(name: "Conifer", targets: ["Conifer"]),
	],
	dependencies: [
		.package(url: "https://github.com/ctxppc/DepthKit.git", .upToNextMinor(from: "0.8.0")),
	],
	targets: [
		.target(name: "Conifer", dependencies: ["DepthKit"]),
		.testTarget(name: "ConiferTests", dependencies: ["Conifer"]),
	]
)
