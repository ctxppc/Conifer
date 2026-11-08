// swift-tools-version:6.4

// Conifer © 2019–2026 Constantino Tsarouhas

import CompilerPluginSupport
import PackageDescription

let package = Package(
	name: "Conifer",
	platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
	products: [
		.library(name: "Conifer", targets: ["Conifer"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-syntax", from: "604.0.0"),
		.package(url: "https://github.com/ctxppc/DepthKit", .upToNextMinor(from: "0.16.0")),
		.package(url: "https://github.com/philipturner/swift-reflection-mirror", branch: "main"),
	],
	targets: [
		
		.target(
			name: "Conifer",
			dependencies: [
				"ConiferMacros",
				"DepthKit",
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
		
	],
	swiftLanguageModes: [.v6]
)
