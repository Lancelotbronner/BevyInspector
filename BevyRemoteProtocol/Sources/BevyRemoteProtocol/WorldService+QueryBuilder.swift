//
//  WorldService+QueryBuilder.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import OpenRPC

public struct QueryService: Sendable {
	public let client: OpenRPCClient
	public var query = Query()
}

public extension QueryService {
	mutating func modify(_ modifier: (inout Query) -> Void) -> QueryService {
		modifier(&query)
		return self
	}

	mutating func with(_ components: some Sequence<String>) -> QueryService {
		modify { $0.data.components.append(contentsOf: components) }
	}
}
