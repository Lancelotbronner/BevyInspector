//
//  WorldService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import OpenRPC

public struct WorldService: Sendable {
	public let client: OpenRPCClient
}

public extension WorldService {
	func query() -> QueryService {
		QueryService(client: client)
	}

	func query(_ query: Query) async throws -> QueryResult {
		try await client.invoke(method: "world.query", with: query)
	}

	func query(data: QueryData, filter: QueryFilter = QueryFilter(), strict: Bool = false) async throws -> QueryResult {
		var query = Query()
		query.data = data
		query.filter = filter
		query.strict = strict
		return try await self.query(query)
	}
}

