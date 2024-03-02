// swift-tools-version:5.9

// Conifer © 2019–2024 Constantino Tsarouhas

import PackageDescription
import CompilerPluginSupport

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
		.package(url: "https://github.com/apple/swift-syntax", from: "509.0.0")
	],
	targets: [
		
		.target(
			name: "Conifer",
			dependencies: [
				"ConiferMacros",
				"DepthKit",
				.product(name: "Collections", package: "swift-collections"),
				.product(name: "ReflectionMirror", package: "swift-reflection-mirror"),
			],
			swiftSettings: [.enableExperimentalFeature("FreestandingMacros")]
		),
		.testTarget(name: "ConiferTests", dependencies: ["Conifer"]),
		
		.macro(name: "ConiferMacros", dependencies: [
			"DepthKit",
			.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
			.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
		]),
		
	]
)
