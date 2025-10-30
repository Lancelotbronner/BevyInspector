//
//  WorldUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol
import OpenRPC

struct WorldList: View {
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

struct WorldDetail: View {
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
				EntityForm(model: results.model(of: entity))
			}
		}
		.task(id: view.query) { try! await refresh() }
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
