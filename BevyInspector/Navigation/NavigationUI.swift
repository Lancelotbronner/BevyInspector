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
			Sidebar(navigation: navigation)
				.frame(minWidth: 180)
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
