//
//  RpcService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//


public struct RpcService: Sendable {
	public let client: OpenRPCClient
}

public extension RpcService {
	func discover() async throws -> Specification {
		try await client.invoke(method: "rpc.discover", with: Empty())
	}
}
