//
//  NavigationUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI

struct NavigationView: View {
	@Environment(Navigation.self) private var navigation

	var body: some View {
		@Bindable var navigation = navigation
		NavigationSplitView {
			List(selection: $navigation.tab) {
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
		} content: {
			switch navigation.tab {
			case .world: WorldList()
			case .queries: QueriesList()
			case .schema: SchemaList()
			default: Spacer()
			}
		} detail: {
			NavigationStack(path: $navigation.path) {
				switch navigation.tab {
				case .world: WorldDetail()
				case .queries: QueriesDetail(view: navigation.query)
				case .schema: SchemaDetail()
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
