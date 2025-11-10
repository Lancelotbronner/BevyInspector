//
//  BevyRemoteProtocol+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol

extension EnvironmentValues {
	@Entry var bevy = BevyRemoteClient(client: OpenRPCClient())
}

nonisolated extension SchemaType {
	var isEmpty: Bool {
		switch self {
		case let .Struct(properties, _, _): properties.isEmpty
		case let .Tuple(v), let .TupleStruct(v): v.prefixItems.isEmpty
		case .Value: true
		default: false
		}
	}
}

nonisolated extension SchemaKind {
	var title: LocalizedStringKey {
		switch self {
		case .Array: "Array"
		case .Struct, .Object: "Struct"
		case .Enum: "Enum"
		case .Map: "Map"
		case .List: "List"
		case .Tuple: "Tuple"
		case .Set: "Set"
		case .Value: "Value"
		case .TupleStruct: "TupleStruct"
		}
	}
}

nonisolated struct InspectorService: Sendable {
	public let client: OpenRPCClient
}

nonisolated extension BevyRemoteClient {
	var inspector: InspectorService {
		InspectorService(client: client)
	}
}

nonisolated extension InspectorService {
	func trigger(_ event: String, payload: some Codable) async throws {
		_ = try await client.invoke(method: "inspector.trigger_event", with: Trigger(event: event, payload: payload), as: Empty?.self)
	}

	func trigger(_ event: String) async throws {
		try await trigger(event, payload: Optional<Empty>.none)
	}

	private struct Trigger<Payload: Codable>: Codable {
		public var event: String
		public var payload: Payload
	}
}
