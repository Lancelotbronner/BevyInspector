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
		case .u8: FormattedEditor(value: $data.u8 ?? 0, format: .number)
		case .u16: FormattedEditor(value: $data.u16 ?? 0, format: .number)
		case .u32: FormattedEditor(value: $data.u32 ?? 0, format: .number)
		case .u64: FormattedEditor(value: $data.u64 ?? 0, format: .number)
		case .usize: FormattedEditor(value: $data.usize ?? 0, format: .number)
		case .i8: FormattedEditor(value: $data.i8 ?? 0, format: .number)
		case .i16: FormattedEditor(value: $data.i16 ?? 0, format: .number)
		case .i32: FormattedEditor(value: $data.i32 ?? 0, format: .number)
		case .i64: FormattedEditor(value: $data.i64 ?? 0, format: .number)
		case .isize: FormattedEditor(value: $data.isize ?? 0, format: .number)
		case .f32: FormattedEditor(value: $data.float ?? 0, format: .number)
		case .f64: FormattedEditor(value: $data.double ?? 0, format: .number)
		case .bool: Toggle("Value", isOn: $data.bool ?? false).labelsHidden()
		case .String: TextField("Value", text: $data.string ?? "").labelsHidden()
		case .Entity: EntityEditor(data: $data).labelsHidden()
		case .Vec2: Vec2Editor(data: $data[SIMD2<Float>.self] ?? .zero)
		case .Vec3, .Vec3A: Vec3Editor(data: $data[SIMD3<Float>.self] ?? .zero)
		case .Transform: TransformEditor(data: $data[Transform.self] ?? Transform())
		case .GlobalTransform: TransformEditor(data: ($data[GlobalTransformComponent.self] ?? .init()).rawValue.transform)
		default:
			switch type.kind {
			case .Struct:
				StructEditor(data: $data, type: type)
			case .TupleStruct, .Tuple:
				TupleEditor(data: $data, type: type)
			case .Enum:
				EnumEditor(data: $data, type: type)
			default:
				let _ = print(type.kind, type, data.description)
				Form {
					LabeledContent {
						Text(data.description)
							.font(.caption.monospaced())
					} label: {
						VStack(alignment: .leading) {
							Text(type.name)
							Text(type.kind.rawValue)
						}
						.monospaced()
						.foregroundStyle(.secondary)
					}
				}
			}
		}
	}
}

public enum BuiltinSchema: String, CaseIterable {
	case i8, i16, i32, i64, isize
	case u8, u16, u32, u64, usize
	case f32, f64
	case bool
	case String = "alloc::string::String"
	case Entity = "bevy_ecs::entity::Entity"
	case Vec2 = "glam::Vec2"
	case Vec3 = "glam::Vec3"
	case Vec3A = "glam::Vec3A"
	case Transform = "bevy_transform::components::transform::Transform"
	case GlobalTransform = "bevy_transform::components::global_transform::GlobalTransform"
}
