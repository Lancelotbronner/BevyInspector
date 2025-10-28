//
//  TypeUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import SwiftData

struct TypeLabel: View {
	let data: BevyType

	var body: some View {
		Text(data.identifier)
			.monospaced()
	}
}

struct TypeForm: View {
	@State private var presented: IdentifiedSchema?
	let data: BevyType

	var body: some View {
		Form {
			Section("Type") {
				LabeledContent("Identifier", value: data.identifier)
			}
			if !data.properties.isEmpty {
				Section("Properties") {
					ForEach(data.properties) { property in
						PropertyLabel(data: property)
					}
				}
			}
		}
		.formStyle(.grouped)
		.sheet(item: $presented) { presented in
			NavigationStack {
				Form {
					SchemaInspector(schema: presented.schema)
				}
				.formStyle(.grouped)
				.navigationTitle("Schema")
			}
		}
		.toolbar {
			if let schema = data.schema {
				Button("View Schema") {
					presented = IdentifiedSchema(type: data, schema: schema)
				}
			}
		}
	}
}

private struct IdentifiedSchema: Identifiable {
	let type: BevyType
	let schema: BevySchema

	var id: BevyType.ID { type.id }
}
