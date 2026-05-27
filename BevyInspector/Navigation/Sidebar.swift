//
//  Sidebar.swift
//  Bevy
//
//  Created by Christophe Bronner on 2026-05-27.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct Sidebar: View {
	@Bindable var navigation: NavigationModel

	var body: some View {
		Picker("Tab", selection: $navigation.sidebar) {
			Label("Project", systemImage: "folder")
				.tag(SidebarTab.project)
			Label("Inspector", systemImage: "info.circle")
				.tag(SidebarTab.inspector)
		}
		switch navigation.sidebar {
		case .project: ProjectSidebar(navigation: navigation)
		case .inspector: InspectorSidebar(navigation: navigation)
		}
	}
}

enum SidebarTab {
	case project
	case inspector
}

private struct ProjectSidebar: View {
	@Bindable var navigation: NavigationModel

	var body: some View {
		List(selection: $navigation.tab) {
			CratesSection()
		}
		HStack {
			AddToWorkspace()
				.labelStyle(.iconOnly)
		}
	}
}

private struct InspectorSidebar: View {
	@Bindable var navigation: NavigationModel

	var body: some View {
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
	}
}

struct AddToWorkspace: View {
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

struct CratesSection: View {
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
