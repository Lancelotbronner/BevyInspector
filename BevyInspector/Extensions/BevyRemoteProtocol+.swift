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
