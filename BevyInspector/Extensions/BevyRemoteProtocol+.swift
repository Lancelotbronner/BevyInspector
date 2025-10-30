//
//  BevyRemoteProtocol+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC

extension EnvironmentValues {
	@Entry var bevy = BevyRemoteClient(client: OpenRPCClient())
}

extension SchemaKind {
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
	var properties: [String: JSON]? {
		switch self {
		case let .Struct(properties, _, _): properties
		default: nil
		}
	}

	var required: [String]? {
		switch self {
		case let .Struct(_, v, _): v
		default: nil
		}
	}

	var title: LocalizedStringKey {
		switch self {
		case .Array: "Array"
		case .Struct: "Struct"
		case .Enum: "Enum"
		case .Map: "Map"
		case .List: "List"
		case .Tuple: "Tuple"
		case .Set: "Set"
		case .Value: "Value"
		case .Ref: "Ref"
		case .TupleStruct: "TupleStruct"
		}
	}
}
