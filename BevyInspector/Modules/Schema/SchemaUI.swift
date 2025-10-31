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
				if let reflect = data.reflect {
					LabeledContent("Reflect") {
						Text(reflect.joined(separator: ", "))
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
					SchemaLabel(data: key)
				}
			}
			if let value = type.items {
				LabeledContent("Value") {
					SchemaLabel(data: value)
				}
			}
		case .Enum:
			ForEach(type.variants) { variant in
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
					SchemaLabel(data: items)
				}
			}
		case .Tuple, .TupleStruct:
			ForEach(type.elements.enumerated(), id: \.offset) { (i, item) in
				LabeledContent {
					SchemaLabel(data: item)
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
		ForEach(type.properties) { property in
			LabeledContent {
				SchemaLabel(data: property.type)
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

struct SchemaLabel: View {
	let data: BevyType

	var body: some View {
		Text(data.name)
			.help(data.identifier)
			.textSelection(.enabled)
			.monospaced()
	}
}
