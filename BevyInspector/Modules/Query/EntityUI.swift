//
//  EntityUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol

struct EntityForm: View {
	@Environment(SchemaUpdateModel.self) private var schema
	@Query private var types: [BevyType]
	let model: QueryRow

	var body: some View {
		Form {
			Section("Entity") {
				LabeledContent("ID") {
					Text(model.id, format: .number.grouping(.never))
						.monospaced()
				}
				LabeledContent("Name", value: model.Name ?? "")
			}
			if let progress = schema.progress {
				ProgressView(progress)
			}
			ForEach(model.columns) { column in
				if let type = types.first(where: {$0.identifier == column.description }), let data = model.value(of: column) {
					ComponentField(.constant(data), as: type)
				} else {
					Text(column.description)
						.monospaced()
						.foregroundStyle(.tertiary)
				}
			}
		}
//		.formStyle(InspectorFormStyle())
	}
}

struct EntityCell: View {
	let row: QueryRow

	var body: some View {
		VStack(alignment: .leading) {
			let name = row.Name
			if let name {
				Text(name)
			}
			Text(row.entity, format: .number.grouping(.never))
				.foregroundStyle(name == nil ? .secondary : .tertiary)
				.font(name == nil ? .body : .caption)
		}
	}
}
