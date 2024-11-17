// swift-tools-version:6.0

// Conifer © 2019–2024 Constantino Tsarouhas

import CompilerPluginSupport
import PackageDescription

let package = Package(
	name: "Conifer",
	platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v9), .visionOS(.v1)],
	products: [
		.library(name: "Conifer", targets: ["Conifer"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMinor(from: "1.2.0")),
		.package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
		.package(url: "https://github.com/ctxppc/DepthKit.git", .upToNextMinor(from: "0.10.0")),
		.package(url: "https://github.com/philipturner/swift-reflection-mirror", branch: "main"),
	],
	targets: [
		
		.target(
			name: "Conifer",
			dependencies: [
				"ConiferMacros",
				"DepthKit",
				.product(name: "Algorithms", package: "swift-algorithms"),
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
