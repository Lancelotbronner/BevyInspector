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
	let row: QueryRow

	var body: some View {
		Form {
			Section("Entity") {
				LabeledContent("ID", value: row.entity.id.rawValue, format: .number.grouping(.never))
				LabeledContent("Name", value: row.name ?? "")
			}
			ForEach(row.columns) { column in
				Section {
					Text(row[column]!.description)
						.foregroundStyle(.secondary)
						.font(.caption)
				} header: {
					Text(column.id)
						.foregroundStyle(.primary)
				}
			}
		}
		.monospaced()
	}
}
