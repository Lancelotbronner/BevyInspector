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
	@Environment(\.bevy) private var bevy
	@Query private var types: [BevyType]
	let _model: ObservableQueryRow

	init(row: QueryRow) {
		_model = ObservableQueryRow(row: row)
	}

	private var model: QueryRow {
		_read { yield _model.row }
		nonmutating _modify { yield &_model.row }
	}

	var body: some View {
		Form {
			Section("Entity") {
				LabeledContent("ID") {
					Text(model.id.description)
						.monospaced()
				}
				LabeledContent("Name", value: model.Name ?? "")
			}
			if let progress = schema.progress {
				ProgressView(progress)
			}
			ForEach(model.columns) { column in
				if let type = types.first(where: { $0.identifier == column.description }), let data = model.value(of: column) {
					ComponentField(.constant(data), as: type)
				} else {
					Text(column.description)
						.monospaced()
						.foregroundStyle(.tertiary)
				}
			}
		}
//		.formStyle(InspectorFormStyle())
		.task(id: model.id) {
			do {
				for try await event in try await bevy.world.entity(model.entity).components.watch(model.columns.lazy.map(\.description)) {
					withAnimation {
						for (component, newValue) in event.components {
							model.components[component] = newValue
						}
						for removed in event.removed {
							model.components[removed] = nil
						}
					}
				}
			} catch let error as CancellationError {
				// ignore
			} catch {
				print(error)
			}
		}
	}
}

struct EntityCell: View {
	let row: QueryRow

	var body: some View {
		VStack(alignment: .leading) {
			let name = row.Name
			name.map(Text.init) ?? Text("Unnamed").foregroundStyle(.secondary)
			Text(row.entity.description)
				.foregroundStyle(.secondary)
				.font(.caption)
				.monospaced()
		}
		.lineLimit(1, reservesSpace: true)
	}
}
