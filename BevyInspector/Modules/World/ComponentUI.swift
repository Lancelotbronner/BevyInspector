//
//  ComponentUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC
import RealityKit
import Spatial

struct DefaultComponentUI: ComponentUI {
	@Binding var data: JSON

	var body: some View {
		Text(data.description)
			.foregroundStyle(.secondary)
			.font(.caption.monospaced())
	}
}

struct Vec3UI: ComponentUI {
	@Binding var data: SIMD3<Float>

	var body: some View {
		Vec3Fields(data: $data)
	}
}

struct TransformUI: ComponentUI {
	@Binding var data: Transform

	var body: some View {
		TransformEditor(data: $data)
	}

	var header: some View {
		//TODO: Find the reality kit icon
		Label("Local", systemImage: "move.3d")
			.font(.caption)
			.foregroundStyle(.secondary)
	}
}

struct GlobalTransformUI: ComponentUI {
	@Binding var data: Transform

	var body: some View {
		TransformEditor(data: $data)
	}

	static func component(data: JSON) throws -> Transform {
		try data.decode(as: GlobalTransformComponent.self).rawValue.transform
	}

	var header: some View {
		Label("Global", systemImage: "move.3d")
			.font(.caption)
			.foregroundStyle(.secondary)
	}
}
