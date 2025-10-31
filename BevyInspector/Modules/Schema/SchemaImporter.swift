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

	func `import`(
		registry: [String: BevySchema],
		specification: Specification,
		progress: Progress
	) async throws {
		for (key, schema) in specification.components.schemas {
			print(key, schema.description)
		}
		await MainActor.run {
			progress.completedUnitCount = 0
			progress.totalUnitCount = 0
			progress.localizedDescription = String(localized: "Indexing types...")
		}

		try modelContext.transaction {
			for (typeId, typeSchema) in registry {
				let currentType = BevyType(typeId)
				currentType.identifier = typeSchema.typePath ?? currentType.identifier
				currentType.name = typeSchema.shortPath ?? currentType.name
				currentType.module = typeSchema.modulePath ?? currentType.module
				currentType.crate = typeSchema.crateName ?? currentType.crate
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
			progress.totalUnitCount = Int64(registry.count)
		}

		try modelContext.transaction {
			for (typeId, typeSchema) in registry {
				let currentType = type(typeId)
				progress.localizedAdditionalDescription = typeId
				ingest(typeSchema.type, into: currentType)
				progress.completedUnitCount += 1
			}
		}
	}

	private func ingest(_ schemaType: SchemaType, into currentType: BevyType) {
		currentType.kind = schemaType.discriminator
		switch schemaType {
		case let .Struct(properties, required, additional):
			currentType.properties = []
			if additional {
				currentType.kind = .Object
			}
			for (propertyId, propertySchema) in properties {
				guard let propertyData = try? propertySchema.decode(as: SchemaReference.self) else { continue }
				let currentProperty = BevyProperty(
					propertyId,
					is: type(propertyData.type.ref.dropFirst(8)),
					required: required.contains(propertyId),
					in: currentType)
				modelContext.insert(currentProperty)
				currentType.properties.append(currentProperty)
			}

		case let .Enum(variants):
			currentType.variants = []
			for variantSchema in variants {
				var type: BevyType?
				if !variantSchema.type.isEmpty {
					let tmp = self.type("\(currentType.identifier)::\(variantSchema.shortPath)")
					ingest(variantSchema.type, into: tmp)
					tmp.module = currentType.module
					tmp.crate = currentType.crate
					type = tmp
				}

				let currentVariant = BevyVariant(
					name: variantSchema.shortPath,
					identifier: variantSchema.typePath,
					is: type,
					in: currentType)
				modelContext.insert(currentVariant)
				currentType.variants.append(currentVariant)
			}

		case let .Array(schema), let .List(schema), let .Set(schema):
			currentType.items = self.type(schema.items.identifier)

		case let .Tuple(schema), let .TupleStruct(schema):
			currentType.elements = schema.prefixItems.map(\.identifier).map(type)

		case let .Map(key, value):
			currentType.key = type(key.identifier)
			currentType.items = type(value.identifier)

		case .Ref(_): fatalError()
		case .Value: break
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
