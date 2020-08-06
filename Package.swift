// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Conifer",
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
