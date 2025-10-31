//
//  Bevy.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftData
import BevyRemoteProtocol
import Foundation

@Model final class BevyType {
	init(_ identifier: String) {
		self.identifier = identifier
		name = identifier.rust_use()
	}

	#Index<BevyType>([\.identifier])

	@Attribute(.unique)
	var identifier = ""

	public var module: String?
	public var crate: String?
	public var reflect: [String]?

	var name = ""
	var kind = SchemaKind.Value

	var key: BevyType?
	var items: BevyType?

	@Relationship(inverse: \BevyType.tuples)
	var elements: [BevyType] = []
	var tuples: [BevyType] = []

	@Relationship(deleteRule: .cascade, inverse: \BevyVariant.parent)
	var variants: [BevyVariant] = []

	@Relationship(deleteRule: .cascade, inverse: \BevyProperty.parent)
	var properties: [BevyProperty] = []
}

extension BevyType: CustomDebugStringConvertible {
	var debugDescription: String { identifier }

	var isEmpty: Bool {
		switch kind {
		case .Struct, .Object: properties.isEmpty
		case .Tuple, .TupleStruct: elements.isEmpty
		case .Enum: variants.isEmpty
		case .Value: true
		default: false
		}
	}

	func variant(_ name: String) -> BevyVariant? {
		variants.first { $0.name == name }
	}
}

@Model final class BevyProperty {
	init(_ identifier: String, is type: BevyType, required: Bool, in parent: BevyType) {
		self.type = type
		self.parent = parent
		self.required = required
		self.identifier = identifier
	}

	#Unique<BevyProperty>([\.parent, \.identifier])

	var parent: BevyType?
	var identifier: String

	var type: BevyType
	var required = true
}

@Model final class BevyVariant {
	init(name: String, identifier: String?, is type: BevyType?, in parent: BevyType) {
		self.type = type
		self.parent = parent
		self.name = name
		self.identifier = identifier
	}

	#Unique<BevyVariant>([\.parent, \.name])

	var parent: BevyType?
	var name: String
	var identifier: String?

	var type: BevyType?
}

@Model final class BevyUse {
	init(replace pattern: String, with replacement: String) {
		self.pattern = pattern
		self.replacement = replacement
	}

	#Unique<BevyUse>([\.pattern])

	var pattern: String
	var replacement: String
}
