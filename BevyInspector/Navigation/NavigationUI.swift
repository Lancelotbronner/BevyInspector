//
//  NavigationUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct NavigationView: View {
	@Environment(NavigationModel.self) private var navigation

	var body: some View {
		@Bindable var navigation = navigation
		NavigationSplitView {
			List(selection: $navigation.tab) {
				NavigationLink("Game", value: NavigationTab.game)
				Section("World") {
					NavigationLink("World", value: NavigationTab.world)
					NavigationLink("Query", value: NavigationTab.queries)
					NavigationLink("Triggers", value: NavigationTab.triggers)
				}
				Section("Registry") {
					NavigationLink("Schema", value: NavigationTab.schema)
					NavigationLink("Methods", value: NavigationTab.methods)
				}
			}
			HStack {
				AddToWorkspace()
			}
		} content: {
			switch navigation.tab {
			case .world: WorldList()
			case .queries: QueriesList()
			case .triggers: TriggerList()
			case .schema: SchemaList()
			case .methods: MethodsList()
			default: Spacer()
			}
		} detail: {
			NavigationStack(path: $navigation.path) {
				switch navigation.tab {
				case .game: GameDetail()
				case .world: WorldDetail()
				case .queries: QueriesDetail(view: navigation.query)
				case .triggers: TriggerDetail()
				case .schema: SchemaDetail()
				case .methods: MethodsDetail()
				case let .crate(crate): CrateDetail(model: crate)
				default: Spacer()
				}
			}
		}
#if false
		TabView(selection: $tab) {
			Tab("World", systemImage: "cube", value: .world) {
				WorldTab()
			}
			Tab("Schema", systemImage: "cube", value: .schema) {
				SchemaTab()
			}
			Tab("Methods", systemImage: "cube", value: .methods) {
				MethodsTab()
			}
		}
		.tabViewStyle(.sidebarAdaptable)
#endif
	}
}

private struct AddToWorkspace: View {
	@Environment(\.modelContext) private var modelContext
	@State private var isPresented = false

	var body: some View {
		Menu("Add to Workspace") {
			Button("New Crate") {
				isPresented = true
			}
		}
		.fileImporter(isPresented: $isPresented, allowedContentTypes: [.folder]) { result in
			if let url = try? result.get() {
				let model = CrateModel()
				model.path = url.absoluteString
				modelContext.insert(model)
			}
		}
	}
}

private struct CratesSection: View {
	@Query private var crates: [CrateModel]

	var body: some View {
		Section("Crates") {
			ForEach(crates) { crate in
				CrateSidebar(model: crate)
					.tag(NavigationTab.crate(crate))
			}
		}
	}
}
