//
//  EntityUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol
import OpenRPC

struct EntityForm: View {
	let model: EntityModel

	var body: some View {
		Form {
			Section("Entity") {
				LabeledContent("ID", value: model.id.rawValue, format: .number.grouping(.never))
				LabeledContent("Name", value: model.row.Name ?? "")
			}
			ForEach(model.query.columns) { column in
				if let data = model.row.value(of: column) {
					Section {
						Text(data.description)
							.foregroundStyle(.secondary)
							.font(.caption)
					} header: {
						Text(column.description)
							.foregroundStyle(.primary)
					}
				}
			}
		}
		.monospaced()
	}
}
