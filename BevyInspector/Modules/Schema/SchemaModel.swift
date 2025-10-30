//
//  SchemaModel.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol
import OSLog

@Observable final class SchemaModel {
	private(set) var isFirstFetchCompleted = false
	private(set) var status = Status.updating
	private(set) var failure: Error?
	private(set) var task: Task<Void, Error>?
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

		task = Task {
			do {
				try await _refresh(modelContainer: modelContainer, bevy: bevy, progress: progress)
			} catch {
				Logger.bevy.critical("\(error.localizedDescription)\n\n\(error)")
				await MainActor.run {
					failure = error
					status = .failure
				}
			}

			await MainActor.run {
				isFirstFetchCompleted = true
				task = nil
				self.progress = nil
			}
		}
	}

	private func _refresh(
		modelContainer: ModelContainer,
		bevy: BevyRemoteClient,
		progress: Progress,
	) async throws {
		async let _registry = try await bevy.registry.schema()
		async let _specification = try await bevy.rpc.discover()

		let (registry, specification) = try await (_registry, _specification)
		let importer = SchemaImporter(modelContainer: modelContainer)

		await MainActor.run { status = .importing }
		try await importer.import(registry: registry, specification: specification, progress: progress)

		await MainActor.run {
			status = .completed
			progress.localizedDescription = String(localized: "Completed.")
		}
	}

	func firstTimeRefresh(
		modelContainer: ModelContainer,
		bevy: BevyRemoteClient,
	) {
		guard !isFirstFetchCompleted, task == nil else { return }
		refresh(modelContainer: modelContainer, bevy: bevy)
	}
}
