//
//  ComponentsService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-30.
//

import OpenRPC

public struct ComponentsService: Sendable {
	public let client: OpenRPCClient
	public let entity: Entity
}

public extension ComponentsService {
	/// Retrieve the values of one or more components from an entity.
	/// - Parameters:
	///   - components: An array of fully-qualified type names of components to fetch.
	func get(_ components: [String]) async throws -> Components {
		try await client.invoke(method: "world.get_components", with: Get(entity: entity, components: components, strict: false))
	}

	/// Retrieve the values of one or more components from an entity.
	/// Strict mode means if any one of the components is not present or can not be reflected an error will be provided.
	/// - Parameters:
	///   - components: An array of fully-qualified type names of components to fetch.
	func get(strictly components: [String]) async throws -> [String: JSON] {
		try await client.invoke(method: "world.get_components", with: Get(entity: entity, components: components, strict: true))
	}

	struct Components: Codable {
		/// A map associating each type name to its value on the requested entity.
		public var components: [String: JSON]
		/// A map associating each type name with an error if it was not on the entity or could not be reflected.
		public var errors: [String: String]
	}

	private struct Get: Codable {
		let entity: Entity
		let components: [String]
		let strict: Bool
	}
}
