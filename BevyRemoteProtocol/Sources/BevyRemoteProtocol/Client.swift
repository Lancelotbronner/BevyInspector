//
//  Client.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//


public struct BevyRemoteClient: Sendable {
	public let client: OpenRPCClient

	public init(client: OpenRPCClient) {
		self.client = client
	}
}

public extension BevyRemoteClient {
	var rpc: RpcService { RpcService(client: client) }
	var registry: RegistryService { RegistryService(client: client) }
	var world: WorldService { WorldService(client: client) }
}
