//
//  CrateUI.swift
//  Bevy
//
//  Created by Christophe Bronner on 2026-02-24.
//

import SwiftUI
import SwiftData

struct CrateSidebar: View {
	@Environment(\.modelContext) private var modelContext
	let model: CrateModel

	var body: some View {
		Label {
			Text(model.path)
		} icon: {
			Text("📦")
		}
		.contextMenu {
			Button("Delete", systemImage: "trash", role: .destructive) {
				modelContext.delete(model)
			}
		}
	}
}

struct CrateDetail: View {
	let model: CrateModel

	var body: some View {
		Form {
			LabeledContent("Path", value: model.path)
		}
	}
}
