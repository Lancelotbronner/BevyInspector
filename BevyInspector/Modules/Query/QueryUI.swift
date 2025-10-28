//
//  QueryUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC

struct QueryList: View {
	@Environment(Navigation.self) private var navigation

	var body: some View {
		List(selection: Bindable(navigation).query) {
			NavigationLink("New Query", value: NavigationQuery.none)
		}
	}
}

struct QueryDetail: View {
	@Environment(\.bevy) private var bevy
	@State private var query = Query()
	@State private var selection: Set<Entity> = []
	@State private var results = QueryResult()

	var body: some View {
		VStack(alignment: .leading) {
			QueryEditor(query: $query)
				.padding([.horizontal, .top])
			QueryView(result: results, selection: $selection)
		}
		.monospaced()
		.inspector(isPresented: .constant(!selection.isEmpty)) {
			if let entity = selection.single {
				EntityForm(row: results[entity])
			}
		}
		.task(id: query) {
			var query = query
			query.data.option.append(QueryColumn.name.id)
			results = try! await bevy.world.query(query)
		}
	}
}

private struct QueryEditor: View {
	@Binding var query: Query
	@State private var text = ""

	var body: some View {
		HStack {
			TextField("Query", text: $text)
				.textFieldStyle(.plain)
				.help(query.description)
				.onChange(of: text) {
					var query = Query()
					if text == "*" {
						query.data.all = true
					} else {
						query.data.components = text.split(separator: ",").map(String.init)
					}
					self.query = query
				}
			Toggle("Strict", isOn: $query.strict)
				.toggleStyle(.checkbox)
		}
	}
}

private struct QueryView: View {
	let result: QueryResult
	@Binding var selection: Set<Entity>

	var body: some View {
		Table(result.rows, selection: $selection) {
			TableColumn("Entity") { row in
				HStack(alignment: .firstTextBaseline) {
					if let name = row.name {
						Text(name)
					} else {
						Text(row.entity.id.rawValue, format: .number.grouping(.never))
							.foregroundStyle(.secondary)
					}
				}
			}
			.width(min: 80, ideal: 0, max: 200)
			TableColumnForEach(result.columns) { column in
				TableColumn(column.id) { row in
					if let data = row[column] {
						Text(data.description)
					}
				}
				.width(min: 80, ideal: 0)
			}
		}
	}
}
