//
//  WorldUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-11-03.
//

import SwiftUI
import SwiftData
import OSLog
import BevyRemoteProtocol

struct WorldList: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(Navigation.self) private var navigation
	@Environment(\.bevy) private var bevy
	@Query private var types: [BevyType]
	@State private var selection: Set<WorldSelection> = []
	@State private var refresh = false
	@State private var resources: [ResourceModel] = []
	@State private var scene = QueryModel(QueryResult())

	var body: some View {
		List(selection: $selection) {
			Section("Scene") {
				OutlineGroup(scene.entities, children: \.children) { entity in
					EntityCell(row: entity.row)
						.listRowSeparator(.hidden)
						.tag(WorldSelection.entity(entity.id))
				}
			}
			Section("Resources") {
				ForEach(resources, id: \.self) { model in
					Text(model.type?.name ?? model.id)
						.monospaced()
						.listRowSeparator(.hidden)
						.tag(WorldSelection.resource(model.id))
				}
			}
		}
		.frame(minWidth: 240)
		.onChange(of: selection.single) {
			switch selection.single {
			case let .entity(id):
				navigation.entity = scene.row(of: id)
				navigation.resource = nil
			case let .resource(type):
				navigation.entity = nil
				navigation.resource = type
			default: break
			}
		}
		.toolbar {
			Button("Refresh") {
				self.refresh.toggle()
			}
		}
		.onAppear { refresh.toggle() }
		.task(id: refresh) {
			OSSignposter.app.emitEvent("WorldList.refresh")
			do {
				try await refresh()
			} catch {
				Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
			}
		}
	}

	private func refresh() async throws {
		do {
			async let scene = bevy.world.query()
				.select(optional: [QueryColumn.Name, .Children, .ChildOf])
				.result()
			async let resources = bevy.world.resources
				.list()
			self.scene = QueryModel(try await scene)
			self.resources = try await resources.map { name in
				let type = types.first { $0.identifier == name }
				return ResourceModel(id: name, type: type)
			}
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

enum WorldSelection: Hashable, Sendable {
	case entity(Entity)
	case resource(String)
}

struct WorldDetail: View {
	@Environment(\.bevy) private var bevy
	@Environment(Navigation.self) private var navigation
	@State private var model: QueryRow?
	@State private var resource: JSON?

	var body: some View {
		VStack {
			if let name = navigation.resource {
				ResourceForm(data: $resource ?? .undefined, name: name)
			} else if let row = model ?? navigation.entity {
				EntityForm(model: row)
			}
		}
		.formStyle(.grouped)
		.task(id: navigation.entity) {
			guard let row = navigation.entity else { return }
			OSSignposter.app.emitEvent("WorldDetail.refresh_entity")
			do {
				try await entity(row.entity)
			} catch {
				Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
			}
		}
		.task(id: navigation.resource) {
			guard let name = navigation.resource else { return }
			OSSignposter.app.emitEvent("WorldDetail.refresh_resource")
			do {
				try await refreshResource(name)
			} catch {
				Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
			}
		}
	}

	private func entity(_ entity: Entity) async throws {
		let components = bevy.world.entity(entity).components
		let names = try await components.list()
		let result = try await components.get(names)
		model = QueryRow(entity, components: result.components)
	}

	private func refreshResource(_ name: String) async throws {
		let value = try await bevy.world.resources.get(name)
		resource = value
	}
}
