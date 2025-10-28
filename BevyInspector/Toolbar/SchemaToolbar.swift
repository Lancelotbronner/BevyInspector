//
//  SchemaToolbar.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol

@Observable final class SchemaModel {
	private(set) var isFirstFetchCompleted = false
	private(set) var status = Status.updating
	private(set) var failure: Error?
	private(set) var fetchingTask: Task<Void, Error>?
	private(set) var progress: Progress?

	enum Status {
		case updating
		case importing
		case completed
		case failure
	}

	func refresh(
		modelContainer: ModelContainer,
		bevy: BevyRemoteClient,
	) {
		let progress = Progress()
		self.progress = progress

		progress.completedUnitCount = 0
		progress.totalUnitCount = 0
		progress.localizedDescription = String(localized: "Requesting schema from server...")
		status = .updating

		fetchingTask = Task { @concurrent in
			do {
				let importer = SchemaImporter(modelContainer: modelContainer)
				let schema = try await bevy.registry.schema()
				await MainActor.run { status = .importing }
				try await importer.import(schema, progress: progress)
				await MainActor.run {
					status = .completed
					progress.localizedDescription = String(localized: "Completed.")
				}
			} catch {
				await MainActor.run {
					failure = error
					status = .failure
				}
			}
			await MainActor.run {
				fetchingTask = nil
				self.progress = nil
			}
		}
	}

	func firstTimeRefresh(
		modelContainer: ModelContainer,
		bevy: BevyRemoteClient,
	) {
		guard !isFirstFetchCompleted else { return }
		isFirstFetchCompleted = true
		refresh(modelContainer: modelContainer, bevy: bevy)
	}
}

struct SchemaToolbar: ToolbarContent {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.bevy) private var bevy
	@Environment(SchemaModel.self) private var schema

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
