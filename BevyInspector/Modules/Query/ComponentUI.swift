//
//  ComponentUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI
import simd
import RealityKit
import Spatial
import BevyRemoteProtocol
import SwiftData
import OSLog

struct ComponentField: View {
//	@State private var isPresented = false
	@Binding var data: JSON
	let type: BevyType

	init(_ data: Binding<JSON>, as type: BevyType) {
		_data = data
		self.type = type
	}

	var body: some View {
		Section {
			ValueEditor(data: $data, type: type)
		} header: {
			HStack(alignment: .firstTextBaseline) {
				Text(type.name)
					.monospaced()
					.textSelection(.enabled)
					.help(type.identifier)
				Spacer()
			}
			.lineLimit(1)
			.buttonStyle(.plain)
//			.sheet(isPresented: $isPresented) {
//				NavigationStack {
//					Form {
//						TextEditor(text: .constant(data.description()))
//							.monospaced()
//							.disabled(true)
//							.navigationTitle(column.description)
//							.scrollContentBackground(.hidden)
//							.frame(maxHeight: .infinity, alignment: .top)
//					}
//					.formStyle(.grouped)
//				}
//				.aspectRatio(3/2, contentMode: .fit)
//			}
//			.contextMenu {
//				Button("View as JSON", systemImage: "curlybraces.ellipsis") {
//					isPresented = true
//				}
//				//TODO: Delete
//				//TODO: Clear overrides
//			}
		}
	}
}

struct StructEditor: View {
	@Binding var data: JSON
	let type: BevyType

	var body: some View {
		Form {
			ForEach(type.properties) { property in
				LabeledContent {
					ValueEditor(data: $data[property.identifier], type: property.type)
				} label: {
					Text(property.identifier)
						.foregroundStyle(.secondary)
				}
			}
		}
	}
}

struct TupleEditor: View {
	@Binding var data: JSON
	let type: BevyType

	var body: some View {
		if !type.elements.isEmpty {
			Form {
				if let type = type.elements.single {
					ValueEditor(data: $data, type: type)
				} else {
					ForEach(type.elements.enumerated(), id: \.offset) { (i, type) in
						LabeledContent {
							ValueEditor(data: $data[i], type: type)
						} label: {
							Text(i.description)
								.foregroundStyle(.secondary)
								.monospaced()
						}
					}
				}
			}
		}
	}
}

struct ListEditor: View {
	@Binding var data: JSON
	let type: BevyType

	var body: some View {
		Form {
			HStack {
				Text("\(data.array?.count ?? 0) items")
				Button("Add Item", systemImage: "plus.circle") {}
					.buttonStyle(.plain)
					.labelStyle(.iconOnly)
			}
			List {
				ForEach(($data.array ?? []).enumerated(), id: \.offset) { (i, $element) in
					LabeledContent {
						ValueEditor(data: $element, type: type)
					} label: {
						Text(i.description)
							.monospaced()
							.foregroundStyle(.secondary)
					}
				}
			}
			.frame(minHeight: 120, alignment: .top)
			.scrollContentBackground(.hidden)
		}
	}
}

struct EnumEditor: View {
	@Binding var data: JSON
	@State private var selection: BevyVariant?
	let type: BevyType

	init(data: Binding<JSON>, type: BevyType) {
		_data = data
		let variant: BevyVariant? = switch data.wrappedValue {
		case let .string(name): type.variant(name)
		case let .object(object): object.keys.single.flatMap(type.variant)
		default: nil
		}
		if let variant {
			_selection = State(initialValue: variant)
		}
		self.type = type
	}

	var body: some View {
		Form {
			VariantPicker(data: $data, selection: $selection, type: type)
			if let selection = selection, let type = selection.type {
				ValueEditor(data: $data[selection.name], type: type)
			}
		}
	}
}

struct OptionEditor: View {
	@Binding var data: JSON
	let type: BevyType

	var body: some View {
		HStack {
			Picker("Variant", selection: $data.null) {
				Text("Some").tag(false)
				Text("None").tag(true)
			}
			.labelsHidden()
			if !data.null, let type = type.variant("Some")?.type {
				ValueEditor(data: $data, type: type)
			}
		}
	}
}

struct VariantPicker: View {
	@Binding var data: JSON
	@Binding var selection: BevyVariant?
	let type: BevyType

	var body: some View {
		Picker("Variant", selection: $selection) {
			ForEach(type.variants) { variant in
				Text(variant.name)
					.tag(variant)
			}
		}
		.labelsHidden()
	}
}

struct EntityEditor: View {
	@Environment(\.bevy) private var bevy
	@Binding var data: JSON
	@State private var text: String
	@State private var suggestions: [QueryRow] = []
	@State private var results = QueryResult()
	@FocusState private var isFocused

	init(data: Binding<JSON>) {
		_data = data
		_text = State(initialValue: data.wrappedValue.usize?.description ?? "")
	}

	var body: some View {
		TextField("Entity", text: $text)
			.onSubmit(of: .text, update)
			.focused($isFocused)
			.textInputSuggestions(suggestions, id: \.entity) { row in
				HStack(alignment: .firstTextBaseline) {
					row.Name.map(Text.init) ?? Text(row.entity.description).foregroundStyle(.secondary)
					Spacer()
					if row.Name != nil {
						Text(row.entity.description)
							.foregroundStyle(.tertiary)
					}
				}
				.textInputCompletion(row.entity.description)
			}
			.monospaced()
			.task {
				guard let entity = data.usize else { return }
				do {
					let components = try await bevy.world
						.entity(entity).components
						.get([QueryColumn.Name])
					if let name = components.Name {
						text = name
					}
				} catch {
					Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
				}
			}
			.task(id: isFocused) {
				guard isFocused else {
					suggestions = []
					return
				}

				do {
					results = try await bevy.world.query()
						.select([QueryColumn.Name])
						.with([QueryColumn.Name])
						.result()
					suggestions = getSuggestions()
				} catch {
					Logger.bevy.fault("\(error.localizedDescription)\n\(error)")
				}
			}
	}

	private func getSuggestions() -> [QueryRow] {
		Array(results.rows.lazy.filter {
			($0.Name?.localizedStandardContains(text) ?? false)
			|| $0.entity.description.localizedStandardContains(text)
		}.prefix(10))
	}

	private func update() {
		if let id = BevyRemoteProtocol.Entity(text) {
			data.usize = id
			if let name = results.row(of: id).flatMap(\.Name) {
				text = name
			}
		} else if let row = results.row(of: text) {
			data.usize = row.entity
		}
	}
}

struct EntityFormat: ParseableFormatStyle {
	typealias FormatInput = BevyRemoteProtocol.Entity?
	let parseStrategy: Strategy

	init(_ data: BevyRemoteProtocol.QueryResult) {
		parseStrategy = Strategy(results: data)
	}

	func format(_ value: FormatInput) -> String {
		value.flatMap(parseStrategy.results.row).flatMap(\.Name) ?? value?.description ?? ""
	}

	struct Strategy: ParseStrategy {
		let results: BevyRemoteProtocol.QueryResult

		func parse(_ value: String) throws -> FormatInput {
			UInt(value) ?? results.rows.first {
				$0.Name == value
			}?.entity
		}
	}
}

struct FormattedEditor<F: ParseableFormatStyle>: View where F.FormatOutput == String {
	@Binding var value: F.FormatInput
	let format: F

	var body: some View {
		TextField("Value", value: $value, format: format)
			.labelsHidden()
	}
}

struct Vec2Editor: View {
	@Binding var data: SIMD2<Float>

	var body: some View {
		Grid {
			GridRow {
				Vec2Fields(data: $data)
			}
		}
	}
}

struct Vec2Fields: View {
	@Binding var data: SIMD2<Float>

	var body: some View {
		Group {
			TextField(value: $data.x, format: .number) {
				Text("x")
					.foregroundStyle(.secondary)
			}
			TextField(value: $data.y, format: .number) {
				Text("y")
					.foregroundStyle(.secondary)
			}
		}
		.textFieldStyle(.roundedBorder)
		.multilineTextAlignment(.center)
	}
}

struct Vec3Editor: View {
	@Binding var data: SIMD3<Float>

	var body: some View {
		Grid {
			GridRow {
				Vec3Fields(data: $data)
			}
		}
	}
}

struct Vec3Fields: View {
	@Binding var data: SIMD3<Float>

	var body: some View {
		Group {
			TextField(value: $data.x, format: .number) {
				Text("x")
					.foregroundStyle(.secondary)
			}
			TextField(value: $data.y, format: .number) {
				Text("y")
					.foregroundStyle(.secondary)
			}
			TextField(value: $data.z, format: .number) {
				Text("z")
					.foregroundStyle(.secondary)
			}
		}
		.textFieldStyle(.roundedBorder)
		.multilineTextAlignment(.center)
	}
}

struct RotationEditor: View {
	@Binding var data: SIMD3<Float>

	var body: some View {
		Group {
			TextField("Yaw", value: $data.x, format: .number)
				.help("Yaw")
			TextField("Pitch", value: $data.y, format: .number)
				.help("Pitch")
			TextField("Roll", value: $data.z, format: .number)
				.help("Roll")
		}
		.textFieldStyle(.roundedBorder)
		.multilineTextAlignment(.center)
		.labelsHidden()
	}
}

struct TransformEditor: View {
	@Binding var data: Transform

	var body: some View {
		Grid {
			GridRow {
				Text("Position")
					.foregroundStyle(.secondary)
					.gridColumnAlignment(.leading)
				Spacer() //TODO: Unit field
				Vec3Fields(data: $data.translation)
					.labelsHidden()
					.frame(maxWidth: 55)
			}
			GridRow {
				Text("Rotation")
					.foregroundStyle(.secondary)
				Spacer() //TODO: Unit field
				RotationEditor(data: $data.rotation.angles)
					.frame(maxWidth: 55)
			}
			GridRow {
				Text("Scale")
					.foregroundStyle(.secondary)
				Spacer() //TODO: Toggle uniform scale
				Vec3Fields(data: $data.scale)
					.labelsHidden()
					.frame(maxWidth: 55)
			}
			GridRow {
				Spacer()
				Spacer()
				Text("x")
				Text("y")
				Text("z")
			}
			.foregroundStyle(.secondary)
		}
		.lineLimit(1)
	}
}

struct VideoModeEditor: View {
	@Binding var data: VideoModeComponent

	var body: some View {
		Form {
			LabeledContent("Resolution") {
				HStack {
					TextField("Width", value: $data.physical_size.x, format: .number.grouping(.never))
					Text(verbatim: "x")
						.foregroundStyle(.secondary)
					TextField("Height", value: $data.physical_size.y, format: .number.grouping(.never))
				}
				.labelsHidden()
			}
			TextField("Refresh Rate", value: $data.refresh_rate_millihertz, format: .number.grouping(.never))
			TextField("Bit Depth", value: $data.bit_depth, format: .number.grouping(.never))
		}
	}
}
