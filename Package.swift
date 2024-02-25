// swift-tools-version:5.9

// Conifer © 2019–2024 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Conifer",
	platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v9), .visionOS(.v1)],
	products: [
		.library(name: "Conifer", targets: ["Conifer"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-collections", branch: "main"),	// TODO: Switch to release when SortedDictionary is officially released.
		.package(url: "https://github.com/ctxppc/DepthKit", .upToNextMinor(from: "0.10.0")),
		.package(url: "https://github.com/philipturner/swift-reflection-mirror", branch: "main"),
	],
	targets: [
		.target(name: "Conifer", dependencies: [
			"DepthKit",
			.product(name: "Collections", package: "swift-collections"),
			.product(name: "ReflectionMirror", package: "swift-reflection-mirror"),
		]),
		.testTarget(name: "ConiferTests", dependencies: ["Conifer"]),
	]
)
