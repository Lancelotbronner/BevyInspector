//
//  RegistryService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import OpenRPC

public struct RegistryService: Sendable {
	public let client: OpenRPCClient

	public init(client: OpenRPCClient) {
		self.client = client
	}
}

public extension RegistryService {
	func schema(
		with_crates: [String] = [],
		without_crates: [String] = [],
		with_components: [String] = [],
		without_components: [String] = [],
	) async throws -> [String: BevySchema] {
		let filter = SchemaFilter(
			with_crates: with_crates,
			without_crates: without_crates,
			type_limit: .init(
				with: with_components,
				without: without_components))
		return try await client.invoke(method: "registry.schema", with: filter)
	}

	private struct SchemaFilter: Codable {
		/// An array of crate names to include in the results.
		/// When empty or omitted, types from all crates will be included.
		var with_crates: [String]?

		/// An array of crate names to exclude from the results.
		/// When empty or omitted, no crates will be excluded.
		var without_crates: [String]?

		/// Additional type constraints.
		var type_limit = TypeLimit()

		struct TypeLimit: Codable {
			/// An array of fully-qualified type names that must be present for a type to be included
			var with: [String]?

			/// An array of fully-qualified type names that must not be present for a type to be excluded
			var without: [String]?
		}
	}
}

