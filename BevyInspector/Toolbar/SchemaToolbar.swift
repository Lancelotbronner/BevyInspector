//
//  SchemaToolbar.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol
import OSLog

struct SchemaToolbar: ToolbarContent {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.bevy) private var bevy
	@Environment(SchemaUpdateModel.self) private var schema

	var body: some ToolbarContent {
		ToolbarItem(placement: .status) {
			Button {
				switch schema.status {
				case .updating, .importing: break
				case .completed, .failure: refresh()
				}
			} label: {
				switch schema.status {
				case .updating:
					Label("Updating...", systemImage: "arrow.down.document")
						.symbolEffect(.wiggle.byLayer, options: .repeat(.continuous), isActive: true)
				case .importing:
					Label("Processing...", systemImage: "gearshape")
						.symbolEffect(.rotate, options: .repeat(.continuous), isActive: true)
				case .completed:
					Label("Refresh", systemImage: "arrow.counterclockwise")
				case .failure:
					Label("Failure", systemImage: "xmark.circle.fill")
						.foregroundStyle(.red)
				}
			}
			.disabled(schema.progress != nil)
			.onAppear {
				schema.firstTimeRefresh(modelContainer: modelContext.container, bevy: bevy)
			}
		}
	}

	private func refresh() {
		schema.refresh(modelContainer: modelContext.container, bevy: bevy)
	}
}
