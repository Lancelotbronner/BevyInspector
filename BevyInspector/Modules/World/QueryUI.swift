//
//  QueryUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol
import OpenRPC

struct QueryEditor: View {
	@Bindable var view: SavedQuery

	var body: some View {
		HStack {
			TextField("Query", text: $view.text)
				.textFieldStyle(.plain)
				.help(view.rust)
				.task(id: view.text) {
					do { try await Task.sleep(for: .seconds(0.5)) }
					catch { return }
					view.parse()
				}
			Toggle("Strict", isOn: $view.query.strict)
				.toggleStyle(.checkbox)
		}
	}
}

struct QueryTableView: View {
	let result: QueryModel
	@Binding var selection: Set<Entity>

	var body: some View {
		Table(result.entities, children: \.children, selection: $selection) {
			TableColumn("Entity") { model in
				HStack(alignment: .firstTextBaseline) {
					if let name = model.row.Name {
						Text(name)
					} else {
						Text(model.id, format: .number.grouping(.never))
							.foregroundStyle(.secondary)
					}
				}
			}
			.width(min: 80, ideal: 0, max: 200)
			TableColumnForEach(result.columns) { column in
				TableColumn(column.description) { model in
					if let data = model.row.value(of: column) {
						Text(data.description)
					}
				}
				.width(min: 80, ideal: 0)
			}
		}
	}

	static let defaultColumns: Set<String> = [
		QueryColumn.Name.description,
		QueryColumn.Children.description,
		QueryColumn.ChildOf.description,
	]

	static func excluded(with query: BevyRemoteProtocol.Query) -> Set<String> {
		defaultColumns.subtracting(query.data.components)
	}

	static func prepare(_ query: inout BevyRemoteProtocol.Query) {
		query.data.option.append(QueryColumn.Name.description)
		query.data.option.append(QueryColumn.Children.description)
		query.data.option.append(QueryColumn.ChildOf.description)
	}
}
