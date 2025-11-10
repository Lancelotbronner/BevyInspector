//
//  QueryUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol
import OSLog

struct QueriesList: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(Navigation.self) private var navigation
	@State private var newQuery = SavedQuery()
	@State private var selection: Set<SavedQuery> = []
	@Query<SavedQuery>(sort: [SortDescriptor(\._name)])
	private var views: [SavedQuery]

	var body: some View {
		List(selection: $selection) {
			NavigationLink("New Query", value: newQuery)
			if !views.isEmpty {
				Section("Views") {
					ForEach(views) { view in
						TextField("Title", text: Bindable(view).name)
							.tag(view)
							.listRowSeparator(.hidden)
					}
				}
			}
		}
		.monospaced()
		.onChange(of: selection, initial: true) {
			navigation.query = selection.single ?? newQuery
			if selection.isEmpty {
				selection.insert(newQuery)
			}
		}
		.contextMenu(forSelectionType: SavedQuery.self) { selection in
			Button("Delete...", systemImage: "trash") {
				selection.forEach(modelContext.delete)
			}
		}
		.toolbar {
			Button("Save Query", systemImage: "document.badge.plus") {
				newQuery.query = newQuery.query
				modelContext.insert(newQuery)
				newQuery = SavedQuery()
			}
		}
	}
}

struct QueriesDetail: View {
	@Environment(\.bevy) private var bevy
	@State private var selection: Set<Entity> = []
	@State private var results = QueryModel(QueryResult())
	@Bindable var view: SavedQuery

	var body: some View {
		VStack(alignment: .leading) {
			QueryEditor(view: view)
					.padding([.horizontal, .top])
			QueryTableView(result: results, selection: $selection)
		}
		.monospaced()
		.inspector(isPresented: .constant(!selection.isEmpty)) {
			if let entity = selection.single {
				EntityForm(model: results.row(of: entity))
					.font(.caption)
			}
		}
		.task(id: view.query) {
			OSSignposter.app.emitEvent("QueriesDetail.refresh")
			do {
				try await refresh()
			} catch {
				Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
			}
		}
	}

	private func refresh() async throws {
		do {
			results = try await QueryModel(query: view.query, using: bevy)
		} catch _ as CancellationError {
			// discard
		} catch let error as URLError {
			if error.code != .cancelled {
				throw error
			}
		} catch {
			throw error
		}
	}
}

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
				if let name = model.row.Name {
					Text(name)
				} else {
					Text(model.row.entity.description)
						.foregroundStyle(.secondary)
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
		.onChange(of: selection) {
			OSSignposter.app.emitEvent("QueryTableView.SelectionChanged")
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
