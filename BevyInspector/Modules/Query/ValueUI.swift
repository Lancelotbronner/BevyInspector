//
//  ValueUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI
import BevyRemoteProtocol
import RealityKit

struct ValueEditor: View {
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
		case .String, .Name: TextField("Value", text: $data.string ?? "").labelsHidden()
		case .Entity: EntityEditor(data: $data).labelsHidden()
		case .Vec2: Vec2Editor(data: $data[SIMD2<Float>.self] ?? .zero)
		case .Vec3, .Vec3A: Vec3Editor(data: $data[SIMD3<Float>.self] ?? .zero)
		case .Transform: TransformEditor(data: $data[Transform.self] ?? Transform())
		case .GlobalTransform: TransformEditor(data: ($data[GlobalTransformComponent.self] ?? .init()).rawValue.transform)
		case .VideoMode: VideoModeEditor(data: $data[VideoModeComponent.self] ?? VideoModeComponent())
		default:
			switch type.kind {
			case .Struct:
				StructEditor(data: $data, type: type)
			case .TupleStruct, .Tuple:
				TupleEditor(data: $data, type: type)
			case .List:
				if let items = type.items {
					ListEditor(data: $data, type: items)
				}
			case .Enum:
				if type.name.starts(with: "Option<") {
					OptionEditor(data: $data, type: type)
				} else {
					EnumEditor(data: $data, type: type)
				}
			default:
				let _ = print(type)
				let _ = print(data.description)
				Form {
					LabeledContent {
						if data != .undefined {
							Text(data.description)
								.monospaced()
						}
					} label: {
						VStack(alignment: .leading) {
							Text(type.name)
							Text(type.kind.rawValue)
						}
						.font(.body.monospaced())
						.foregroundStyle(.secondary)
					}
				}
			}
		}
	}
}

public enum BuiltinSchema: String, CaseIterable {
	// Primitives
	case i8, i16, i32, i64, isize
	case u8, u16, u32, u64, usize
	case f32, f64
	case bool
	// Types
	case String = "alloc::string::String"
	case Entity = "bevy_ecs::entity::Entity"
	// Vectors
	case BVec2 = "glam::BVec2"
	case BVec3 = "glam::BVec3"
	case BVec4 = "glam::BVec4"
	case UVec2 = "glam::UVec2"
	case UVec3 = "glam::UVec3"
	case UVec4 = "glam::UVec4"
	case IVec2 = "glam::IVec2"
	case IVec3 = "glam::IVec3"
	case IVec4 = "glam::IVec4"
	case DVec2 = "glam::DVec2"
	case DVec3 = "glam::DVec3"
	case DVec4 = "glam::DVec4"
	case U8Vec2 = "glam::U8Vec2"
	case U8Vec3 = "glam::U8Vec3"
	case U8Vec4 = "glam::U8Vec4"
	case U16Vec2 = "glam::U16Vec2"
	case U16Vec3 = "glam::U16Vec3"
	case U16Vec4 = "glam::U16Vec4"
	case U64Vec2 = "glam::U64Vec2"
	case U64Vec3 = "glam::U64Vec3"
	case U64Vec4 = "glam::U64Vec4"
	case Vec3A = "glam::Vec3A"
	case Vec2 = "glam::Vec2"
	case Vec3 = "glam::Vec3"
	case Vec4 = "glam::Vec4"
	// Components
	case Name = "bevy_ecs::name::Name"
	case Transform = "bevy_transform::components::transform::Transform"
	case GlobalTransform = "bevy_transform::components::global_transform::GlobalTransform"
	case VideoMode = "bevy_window::monitor::VideoMode"
}
