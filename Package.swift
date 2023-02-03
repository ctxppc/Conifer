// swift-tools-version:5.7

// Conifer © 2019–2023 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Conifer",
	platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)],
	products: [
		.library(name: "Conifer", targets: ["Conifer"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-collections", from: "1.0.4"),
		.package(url: "https://github.com/ctxppc/DepthKit", .upToNextMinor(from: "0.10.0")),
	],
	targets: [
		.target(name: "Conifer", dependencies: [
			"DepthKit",
			.product(name: "Collections", package: "swift-collections"),
		]),
		.testTarget(name: "ConiferTests", dependencies: ["Conifer"]),
	]
)
