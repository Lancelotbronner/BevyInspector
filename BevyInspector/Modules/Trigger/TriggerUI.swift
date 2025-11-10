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
	var type: BevyType?
	var data = JSON.undefined
}

struct TriggerList: View {
	var body: some View {

	}
}

struct TriggerDetail: View {
	@Environment(\.bevy) private var bevy
	@State private var failure: Error?
	@State private var model = TriggerModel()

	var body: some View {
		@Bindable var model = model
		Form {
			Section {
				TypeField(type: $model.type) {
					Text("Event")
				}
				LabeledContent("Payload") {
					Text(model.data.description())
						.monospaced()
				}
				if let failure {
					LabeledContent("Failure") {
						Text(verbatim: "\(failure)")
							.foregroundStyle(.red)
					}
				}
			}
			if let type = model.type {
				ValueEditor(data: $model.data, type: type)
			}
		}
		.formStyle(.grouped)
		.toolbar {
			Button("Send", systemImage: "arrow.up") {
				guard let type = model.type else { return }
				Task {
					do {
						try await bevy.inspector.trigger(type.identifier, payload: model.data)
						failure = nil
					} catch {
						failure = error
					}
				}
			}
			.tint(.accentColor)
			.disabled(model.type == nil)
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
