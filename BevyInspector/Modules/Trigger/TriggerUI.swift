//
//  TriggerUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-11-09.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol

@Observable final class TriggerModel {
	var data = JSON.undefined
	var failure: Error?
}

struct TriggerList: View {
	@Environment(Navigation.self) private var navigation
	@Query(
		filter: #Predicate<BevyType> { $0.reflect.contains { $0.identifier == "Event" } },
		sort: \.name)
	private var events: [BevyType]
	@Query private var reflects: [BevyReflect]

	var body: some View {
		List(events, selection: Bindable(navigation).event) {
			TypeLabel(data: $0)
				.tag($0)
				.listRowSeparator(.hidden)
		}
	}
}

struct TriggerDetail: View {
	@Environment(Navigation.self) private var navigation
	@Environment(\.bevy) private var bevy
	@State private var model = TriggerModel()

	var body: some View {
		VStack(alignment: .leading) {
			if let type = navigation.event {
				EventForm(model: model, type: type)
			}
		}
		.formStyle(.grouped)
		.toolbar {
			Button("Send", systemImage: "arrow.up") {
				guard let type = navigation.event else { return }
				Task {
					do {
						try await bevy.inspector.trigger(type.identifier, payload: model.data)
						model.failure = nil
					} catch {
						model.failure = error
					}
				}
			}
			.tint(.accentColor)
			.disabled(navigation.event == nil)
		}
	}
}

private struct EventForm: View {
	@Bindable var model: TriggerModel
	let type: BevyType

	var body: some View {
		Form {
			Section {
				LabeledContent("Payload") {
					Text(model.data.description)
						.monospaced()
				}
				if let failure = model.failure {
					LabeledContent("Failure") {
						Text(verbatim: "\(failure)")
							.foregroundStyle(.red)
					}
				}
			} header: {
				TypeLabel(data: type)
			}
			Section("Parameters") {
				ValueEditor(data: $model.data, type: type)
			}
		}
	}
}

struct TypeField<Label: View>: View {
	@Environment(\.modelContext) private var modelContext
	@Binding var type: BevyType?
	@State private var text = ""
	@State private var suggestions: [BevyType] = []
	@ViewBuilder var label: Label

	var body: some View {
		TextField(text: $text) {
			label
				.font(.body)
		}
		.monospaced()
		.textInputSuggestions(suggestions) {
			TypeLabel(data: $0)
				.textInputCompletion($0.identifier)
		}
		.onSubmit(of: .text) {
			var descriptor = FetchDescriptor<BevyType>()
			descriptor.fetchLimit = 1
			descriptor.predicate = #Predicate<BevyType> {
				$0.identifier == text
			}
			let results = try! modelContext.fetch(descriptor)
			type = results.first ?? type
			suggestions = []
			print("TypeField.type \(type?.identifier ?? "<nil>")")
		}
		.task(id: text) {
			do { try await Task.sleep(for: .seconds(0.5)) }
			catch { return }
			var descriptor = FetchDescriptor<BevyType>()
			descriptor.fetchLimit = 10
			descriptor.predicate = #Predicate<BevyType> {
				$0.identifier.localizedStandardContains(text)
			}
			do {
				suggestions = try modelContext.fetch(descriptor)
			} catch {
				print(error)
			}
			print("TypeField.suggestions \(suggestions.count)")
		}
		.onChange(of: type, initial: true) {
			text = type?.identifier ?? text
			suggestions = []
		}
	}
}
