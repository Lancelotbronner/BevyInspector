//
//  ResourcesService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-11-05.
//

public struct ResourcesService: Sendable {
	public let client: OpenRPCClient
}

public extension ResourcesService {
	/// List all reflectable registered resource types.
	/// - Returns: An array of fully-qualified type names of registered resource types.
	func list() async throws -> [String] {
		try await client.invoke(method: "world.list_resources", with: Empty?.none)
	}
	
	/// Extract the value of a given resource from the world.
	/// - Parameter resource: The fully-qualified type name of the resource to get.
	/// - Returns: The value of the resource in the world.
	func get(_ resource: some CustomStringConvertible) async throws -> JSON {
		try await client.invoke(method: "world.get_resources", with: Get(resource: resource.description), as: Resources.self).value
	}

	private struct Resources: Codable {
		var value: JSON
	}

	private struct Get: Codable {
		let resource: String
	}
}
