//
//  ComponentEditorUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI
import simd
import RealityKit
import Spatial
import BevyRemoteProtocol
import OpenRPC
import SwiftData

protocol ComponentUI: View {
	associatedtype Component: Codable
	associatedtype Header: View = EmptyView

	var data: Component { get }
	var header: Header { get }

	init(data: Binding<Component>)

	static var isExpandable: Bool { get }
	static var title: Text? { get }

	static func component(data: JSON) throws -> Component
}

extension ComponentUI {
	static var isExpandable: Bool { true }
	static var title: Text? { nil }

	init(data: Binding<JSON>) {
		self.init(data: Binding<Component> {
			try! Self.component(data: data.wrappedValue)
		} set: {
			data.wrappedValue = try! JSON($0)
		})
	}

	static func component(data: JSON) throws -> Component {
		try data.decode()
	}
}

extension ComponentUI where Header == EmptyView {
	var header: Header { EmptyView() }
}

struct ComponentField: View {
	@Query private var type: [BevyType]
	@State private var isExpanded = false
	@State private var isPresented = false
	@Binding var data: JSON
	let column: QueryColumn

	init(_ data: Binding<JSON>, as column: QueryColumn) {
		_data = data
		self.column = column
		let id = column.description
		var descriptor = FetchDescriptor<BevyType>()
		descriptor.fetchLimit = 1
		descriptor.predicate = #Predicate<BevyType> { $0.identifier == id }
		_type = Query(descriptor)
	}

	var body: some View {
		Section(isExpanded: $isExpanded) {
			Group {
				if let type = type.first {
					SchemaValueUI(data: $data, type: type)
				} else {
					DefaultComponentUI(data: $data)
				}
			}
			.font(.caption)
		} header: {
			HStack(alignment: .firstTextBaseline) {
				Text(column.name)
					.monospaced()
					.textSelection(.enabled)
				Spacer()
				Button("View as JSON", systemImage: "curlybraces") {
					isPresented = true
				}
				.labelStyle(.iconOnly)
			}
			.lineLimit(1)
			.buttonStyle(.plain)
			.sheet(isPresented: $isPresented) {
				NavigationStack {
					Form {
						TextEditor(text: .constant(data.description()))
							.monospaced()
							.disabled(true)
							.navigationTitle(column.description)
					}
					.formStyle(.grouped)
				}
			}
			.contextMenu {
				//TODO: Delete
				//TODO: Clear overrides
			}
		}
	}
}

struct Vec3Editor: View {
	@Binding var data: SIMD3<Float>

	var body: some View {
		Group {
			TextField("X", value: $data.x, format: .number)
			TextField("Y", value: $data.y, format: .number)
			TextField("Z", value: $data.z, format: .number)
		}
		.frame(width: 40)
		.textFieldStyle(.roundedBorder)
		.multilineTextAlignment(.center)
		.labelsHidden()
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
		.frame(width: 40)
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
				Text("Translation")
					.foregroundStyle(.secondary)
					.gridColumnAlignment(.leading)
				//TODO: Unit field
				Vec3Editor(data: $data.translation)
			}
			GridRow {
				Text("Rotation")
					.foregroundStyle(.secondary)
				//TODO: Unit field
				RotationEditor(data: $data.rotation.angles)
			}
			GridRow {
				Text("Scale")
					.foregroundStyle(.secondary)
				//TODO: Toggle uniform scale
				Vec3Editor(data: $data.scale)
			}
			GridRow {
				Spacer()
				//					Spacer()
				Text("x")
				Text("y")
				Text("z")
			}
			.foregroundStyle(.secondary)
		}
	}
}
