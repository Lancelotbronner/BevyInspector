//
//  ComponentSchemaUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC
import RealityKit

struct SchemaValueUI: View {
	@Binding var data: JSON
	let type: BevyType

	var body: some View {
		switch BuiltinSchema(rawValue: type.identifier) {
		case .f32:
			TextField("Value", value: $data.float ?? 0, format: .number)
		case .Transform:
			TransformEditor(data: $data[Transform.self] ?? Transform())
		case .GlobalTransform:
			let data = $data[GlobalTransformComponent.self] ?? .init()
			TransformEditor(data: data.rawValue.transform)
		default:
			switch type.schema?.type {
			case .Struct:
				EmptyView()
			default:
				Text(data.description)
					.foregroundStyle(.secondary)
					.font(.caption.monospaced())
			}
			ForEach(type.properties) { property in
				LabeledContent {
					SchemaValueUI(data: $data[property.identifier], type: property.type)
				} label: {
					Text(property.identifier)
						.monospaced()
				}
			}
		}
	}
}

public enum BuiltinSchema: String, CaseIterable {
	case f32
	case Transform = "bevy_transform::components::transform::Transform"
	case GlobalTransform = "bevy_transform::components::global_transform::GlobalTransform"
}
