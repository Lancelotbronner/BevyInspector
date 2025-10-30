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
		Text(data.name.isEmpty ? data.identifier : data.name)
			.help(data.identifier)
			.monospaced()
	}
}

struct TypeForm: View {
//	@State private var presented: IdentifiedSchema?
	let data: BevyType

	var body: some View {
		Form {
			if let schema = data.schema {
				SchemaForm(schema: schema)
			}
		}
		.formStyle(.grouped)
//		.sheet(item: $presented) { presented in
//			NavigationStack {
//				Form {
//					SchemaInspector(schema: presented.schema)
//				}
//				.formStyle(.grouped)
//				.navigationTitle("Schema")
//			}
//		}
//		.toolbar {
//			if let schema = data.schema {
//				Button("View Schema") {
//					presented = IdentifiedSchema(type: data, schema: schema)
//				}
//			}
//		}
	}
}

private struct IdentifiedSchema: Identifiable {
	let type: BevyType
	let schema: BevySchema

	var id: BevyType.ID { type.id }
}
