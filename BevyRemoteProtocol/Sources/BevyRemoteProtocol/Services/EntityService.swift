//
//  EntityService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-30.
//


public struct EntityService: Sendable {
	public let client: OpenRPCClient
	public let entity: Entity
}

public extension EntityService {
	var components: ComponentsService {
		ComponentsService(client: client, entity: entity)
	}
}
