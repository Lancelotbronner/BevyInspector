//
//  SchemaUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC

struct SchemaForm: View {
	let schema: BevySchema

	var body: some View {
		Section {
			LabeledContent("Identifier") {
				Text(schema.typePath ?? "")
					.monospaced()
			}
			if let module_path = schema.modulePath {
				LabeledContent("Module") {
					Text(module_path)
						.monospaced()
				}
			}
			if let crate_name = schema.crateName {
				LabeledContent("Crate") {
					Text(crate_name)
						.monospaced()
				}
			}
			if let reflect_types = schema.reflectTypes {
				LabeledContent("Reflect") {
					Text(reflect_types.joined(separator: ", "))
						.monospaced()
				}
			}
		} header: {
			Text(schema.shortPath ?? "")
				.monospaced()
		}
		if !schema.type.isEmpty {
			Section(schema.type.title) {
				SchemaKindUI(kind: schema.type)
			}
		}
	}
}

private struct SchemaKindUI: View {
	let kind: SchemaKind

	var body: some View {
		switch kind {
		case let .Struct(properties, required, additional):
			ForEach(properties.keys.sorted(), id: \.self) { key in
				PropertySchemaCell(
					key: key,
					property: properties[key]!,
					required: required.contains(key))
			}
			if additional {
				Label("Additional properties", systemImage: "plus")
			}
		case let .Map(key, value):
			Section("Key") {
				SchemaKindUI(kind: key)
			}
			Section("Value") {
				SchemaKindUI(kind: value)
			}
		case let .Enum(variants):
			ForEach(variants.enumerated(), id: \.offset) { (_, variant) in
				Section {
					HStack(alignment: .firstTextBaseline) {
						Text(variant.shortPath)
							.font(.headline.monospaced())
						if let typePath = variant.typePath {
							Text(typePath)
								.font(.caption2.monospaced())
								.foregroundStyle(.tertiary)
						}
					}
					SchemaKindUI(kind: variant.type)
				}
			}
		case let .Array(v), let .List(v), let .Set(v):
			if let property = v.items.property {
				LabeledContent("Element") {
					SchemaPropertyLabel(property)
				}
			} else {
				Text("NONE")
			}
		case let .Tuple(v), let .TupleStruct(v):
			ForEach(v.prefixItems.enumerated(), id: \.offset) { (i, item) in
				LabeledContent {
					SchemaPropertyLabel(item)
				} label: {
					Text(i.description)
						.font(.headline)
						.monospaced()
				}
			}
		case let .Ref(identifier):
			LabeledContent("Type") {
				Text(identifier)
					.monospaced()
			}
		case .Value:
			EmptyView()
		}
	}
}

struct SchemaPropertyLabel: View {
	let property: Result<SchemaReference, Error>

	init(_ property: SchemaReference) {
		self.property = .success(property)
	}

	init(_ property: JSON) {
		self.property = Result { try property.decode() }
	}

	var body: some View {
		switch property {
		case let .success(success):
			let tmp = String(success.type.ref.dropFirst(8))
			Text(tmp.rust_use())
				.help(tmp)
				.monospaced()
				.textSelection(.enabled)
		case let .failure(failure):
			Text(verbatim: "\(failure.localizedDescription)\n\(failure)")
				.foregroundStyle(.red)
				.monospaced()
		}
	}
}

struct PropertySchemaCell: View {
	let key: String
	let property: JSON
	let required: Bool

	var body: some View {
		LabeledContent {
			SchemaPropertyLabel(property)
		} label: {
			HStack(alignment: .firstTextBaseline) {
				Text(key)
					.font(.headline.monospaced())
				IsRequired(required)
			}
		}
	}
}
