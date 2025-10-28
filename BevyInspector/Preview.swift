//
//  Preview.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol
import OpenRPC

struct CommonPreviewModifier: PreviewModifier {
	struct Context {
		let modelContainer = ModelContainer.preview
		let bevy = BevyRemoteClient(client: .init())
	}
	static func makeSharedContext() throws -> Context {
		Context()
	}

	func body(content: Content, context: Context) -> some View {
		content
			.modelContainer(context.modelContainer)
			.environment(\.bevy, context.bevy)
	}
}

extension PreviewTrait<Preview.ViewTraits> {
	static var common: PreviewTrait {
		.modifier(CommonPreviewModifier())
	}
}
