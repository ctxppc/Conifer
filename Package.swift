// swift-tools-version:5.5

// Conifer © 2019–2021 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Conifer",
	platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)],
	products: [
		.library(name: "Conifer", targets: ["Conifer"]),
	],
	dependencies: [
		.package(url: "https://github.com/ctxppc/DepthKit.git", .upToNextMinor(from: "0.9.0")),
	],
	targets: [
		.target(name: "Conifer", dependencies: ["DepthKit"]),
		.testTarget(name: "ConiferTests", dependencies: ["Conifer"]),
	]
)
