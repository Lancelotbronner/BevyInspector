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

	var name = ""
	var schemaKind: String?

	private var schemaData: Data? {
		didSet { schemaCache = nil }
	}

	@Transient private var schemaCache: BevySchema?

	var schema: BevySchema? {
		get {
			if let schemaCache {
				return schemaCache
			}
			guard let schemaData else { return nil }
			let tmp = try! JSONDecoder().decode(BevySchema.self, from: schemaData)
			schemaCache = tmp
			return tmp
		}
		set {
			schemaCache = newValue
			if let newValue {
				schemaData = try! JSONEncoder().encode(newValue)
				schemaKind = newValue.kind ?? schemaKind
			}
		}
	}

	var items: BevyProperty?

	@Relationship(deleteRule: .cascade, inverse: \BevyVariant.parent)
	var variants: [BevyVariant] = []

	@Relationship(deleteRule: .cascade, inverse: \BevyProperty.parent)
	var properties: [BevyProperty] = []
}

@Model final class BevyProperty {
	init(_ identifier: String, is type: BevyType, required: Bool, in parent: BevyType) {
		self.type = type
		self.parent = parent
		self.required = required
		self.identifier = identifier
	}

	#Unique<BevyProperty>([\.parent, \.identifier])

	var parent: BevyType
	var identifier: String

	var type: BevyType
	var required = true
}

@Model final class BevyVariant {
	init(_ identifier: String, is type: BevyType, in parent: BevyType) {
		self.type = type
		self.parent = parent
		self.identifier = identifier
	}

	#Unique<BevyVariant>([\.parent, \.identifier])

	var parent: BevyType
	var identifier: String

	var type: BevyType
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
