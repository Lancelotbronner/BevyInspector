//
//  WorldService+QueryService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import OpenRPC

public struct QueryService: ~Copyable {
	public let client: OpenRPCClient
	public var query = Query()

	init(client: OpenRPCClient) {
		self.client = client
	}
}

public extension QueryService {
	consuming func modify(_ modifier: (inout Query) -> Void) -> QueryService {
		modifier(&query)
		return self
	}

	consuming func with(_ components: some Sequence<some CustomStringConvertible>) -> QueryService {
		modify { $0.filter.with.append(contentsOf: components.lazy.map(\.description)) }
	}

	consuming func select(_ components: some Sequence<some CustomStringConvertible>) -> QueryService {
		modify { $0.data.components.append(contentsOf: components.lazy.map(\.description)) }
	}

	consuming func result() async throws -> QueryResult {
		try await WorldService(client: client).query(query)
	}
}
