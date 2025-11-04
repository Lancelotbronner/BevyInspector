//
//  WorldUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-11-03.
//

import SwiftUI
import OSLog
import BevyRemoteProtocol

struct WorldList: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(Navigation.self) private var navigation
	@Environment(\.bevy) private var bevy
	@State private var selection: Set<Entity> = []
	@State private var refresh = false
	@State private var model = QueryModel(QueryResult())

	var body: some View {
		List(model.entities, children: \.children, selection: $selection) { entity in
			EntityCell(row: entity.row)
				.listRowSeparator(.hidden)
		}
		.monospaced()
		.onChange(of: selection.single) {
			navigation.entity = selection.single.map {
				model.row(of: $0)
			}
		}
		.toolbar {
			Button("Refresh") {
				self.refresh.toggle()
			}
		}
		.onAppear { refresh.toggle() }
		.task(id: refresh) {
			OSSignposter.app.emitEvent("WorldDetail.refresh")
			do {
				try await refresh()
			} catch {
				Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
			}
		}
	}

	private func refresh() async throws {
		OSSignposter.app.emitEvent("WorldList.refresh")
		do {
			let results = try await bevy.world.query()
				.select(optional: [QueryColumn.Name, .Children, .ChildOf])
				.result()
			model = QueryModel(results)
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

struct WorldDetail: View {
	@Environment(\.bevy) private var bevy
	@Environment(Navigation.self) private var navigation
	@State private var model: QueryRow?

	var body: some View {
		VStack {
			if let row = model ?? navigation.entity {
				EntityForm(model: row)
			}
		}
		.formStyle(.grouped)
		.task(id: navigation.entity) {
			if let row = navigation.entity {
				await refresh(row.entity)
			}
		}
	}

	private func refresh(_ entity: Entity) async {
		OSSignposter.app.emitEvent("WorldDetail.refresh")
		do {
			try await _refresh(entity)
		} catch {
			Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
		}
	}

	private func _refresh(_ entity: Entity) async throws {
		let components = bevy.world.entity(entity).components
		let names = try await components.list()
		let result = try await components.get(names)
		model = QueryRow(entity, components: result.components)
	}
}
