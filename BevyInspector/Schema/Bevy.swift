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
	}

	#Index<BevyType>([\.identifier])

	@Attribute(.unique)
	var identifier = ""

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
			}
		}
	}

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
	var identifier = ""

	var type: BevyType
	var required: Bool
}
