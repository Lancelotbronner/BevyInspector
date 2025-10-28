//
//  SchemaImporter.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftData
import BevyRemoteProtocol
import OpenRPC
import Foundation

@ModelActor actor SchemaImporter {
	private var _types: [String: BevyType] = [:]

	func `import`(_ schema: [String: BevySchema], progress: Progress) async throws {
		await MainActor.run {
			progress.completedUnitCount = 0
			progress.totalUnitCount = 0
			progress.localizedDescription = String(localized: "Indexing types...")
		}

		try modelContext.transaction {
			for (typeId, typeSchema) in schema {
				let currentType = BevyType(typeId)
				currentType.schema = typeSchema
				modelContext.insert(currentType)
			}
		}

		await MainActor.run {
			progress.localizedDescription = String(localized: "Preparing to import...")
		}

		var _types = FetchDescriptor<BevyType>()
		_types.propertiesToFetch = [\.identifier]
		self._types = try modelContext.fetch(_types).lookup(by: \.identifier)

		await MainActor.run {
			progress.localizedDescription = String(localized: "Processing schema...")
			progress.completedUnitCount = 0
			progress.totalUnitCount = Int64(schema.count)
		}

		try modelContext.transaction {
			for (typeId, typeSchema) in schema {
				let currentType = type(typeId)
				progress.localizedAdditionalDescription = typeId

				for (propertyId, propertySchema) in typeSchema.properties ?? [:] {
					guard let propertyData = try? propertySchema.decode(as: BevyPropertySchema.self) else { continue }
					let currentProperty = BevyProperty(
						propertyId,
						is: type(propertyData.type.ref.dropFirst(8)),
						required: typeSchema.required?.contains(propertyId) ?? false,
						in: currentType)
					modelContext.insert(currentProperty)
					currentType.properties.append(currentProperty)
				}

					progress.completedUnitCount += 1
			}
		}
	}

	private func type(_ identifier: some CustomStringConvertible) -> BevyType {
		let identifier = identifier.description
		if let type = _types[identifier] {
			return type
		}
		let type = BevyType(identifier)
		modelContext.insert(type)
		return type
	}
}
