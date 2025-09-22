// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "HotlineProtocol",
	platforms: [
		.iOS(.v18),
		.macOS(.v15)
	],
	products: [
		.library(
			name: "HotlineProtocol",
			targets: ["HotlineProtocol"]),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.0.0"),
	],
	targets: [
		.target(
			name: "HotlineProtocol",
			dependencies: [
				.product(name: "Parsing", package: "swift-parsing")
			],
			path: "HotlineProtocol/Source"),
		.testTarget(
			name: "HotlineProtocolTests",
			dependencies: ["HotlineProtocol"],
			path: "HotlineProtocol/Tests"),
	]
)
