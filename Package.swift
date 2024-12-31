// swift-tools-version:6.0

// Conifer © 2019–2024 Constantino Tsarouhas

import CompilerPluginSupport
import PackageDescription

let package = Package(
	name: "Conifer",
	platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v10), .visionOS(.v2)],
	products: [
		.library(name: "Conifer", targets: ["Conifer"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
		.package(url: "https://github.com/ctxppc/DepthKit", .upToNextMinor(from: "0.13.0")),
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
