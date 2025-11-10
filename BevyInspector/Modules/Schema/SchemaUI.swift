//
//  SchemaUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol

struct SchemaForm: View {
	let data: BevyType

	var body: some View {
		Form {
			Section {
				LabeledContent("Identifier") {
					Text(data.identifier)
						.monospaced()
				}
				if let module = data.module {
					LabeledContent("Module") {
						Text(module)
							.monospaced()
					}
				}
				if let crate = data.crate {
					LabeledContent("Crate") {
						Text(crate)
							.monospaced()
					}
				}
				if !data.reflect.isEmpty {
					LabeledContent("Reflect") {
						Text(data.reflect.map(\.identifier).joined(separator: ", "))
							.monospaced()
					}
				}
			} header: {
				Text(data.name)
					.monospaced()
			}
			if !data.isEmpty {
				Section(data.kind.title) {
					SchemaKindUI(type: data)
				}
			}
		}
		.formStyle(.grouped)
	}
}

private struct SchemaKindUI: View {
	let type: BevyType

	var body: some View {
		switch type.kind {
		case .Struct:
			SchemaStruct(type: type)
		case .Object:
			SchemaStruct(type: type)
			Label("Additional properties", systemImage: "plus")
				.foregroundStyle(.secondary)
		case .Map:
			if let key = type.key {
				LabeledContent("Key") {
					TypeLabel(data: key)
				}
			}
			if let value = type.items {
				LabeledContent("Value") {
					TypeLabel(data: value)
				}
			}
		case .Enum:
			ForEach(type.variants.sorted()) { variant in
				Section {
					HStack(alignment: .firstTextBaseline) {
						Text(variant.name)
							.font(.headline.monospaced())
						if let typePath = variant.identifier {
							Text(typePath)
								.font(.caption2.monospaced())
								.foregroundStyle(.tertiary)
						}
					}
					if let type = variant.type {
						SchemaKindUI(type: type)
					}
				}
			}
		case .Array, .List, .Set:
			if let items = type.items {
				LabeledContent("Items") {
					TypeLabel(data: items)
				}
			}
		case .Tuple, .TupleStruct:
			ForEach(type.elements.enumerated(), id: \.offset) { (i, item) in
				LabeledContent {
					TypeLabel(data: item)
				} label: {
					Text(i.description)
						.font(.headline)
				}
				.monospaced()
			}
		case .Value:
			EmptyView()
		}
	}
}

private struct SchemaStruct: View {
	let type: BevyType

	var body: some View {
		ForEach(type.properties.sorted()) { property in
			LabeledContent {
				TypeLabel(data: property.type)
			} label: {
				HStack(alignment: .firstTextBaseline) {
					Text(property.identifier)
						.font(.headline.monospaced())
					IsRequired(property.required)
				}
			}
		}
	}
}
