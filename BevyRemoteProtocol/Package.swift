// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "BevyRemoteProtocol",
	platforms: [
		.macOS(.v26),
	],
	products: [
		.library(name: "BevyRemoteProtocol", targets: [
			"BevyRemoteProtocol", "BevyXPC",
		]),
		.library(name: "BevyKit", targets: [
			"BevyXPC", "CoreBevy",
		])
	],
	targets: [
		.target(name: "Json"),
		.target(name: "BevyRemoteProtocol", dependencies: ["Json"]),
		.target(name: "BevyXPC"),
		.target(name: "CoreBevy"),
		.target(name: "Cargo", dependencies: ["Json"]),
	]
)
