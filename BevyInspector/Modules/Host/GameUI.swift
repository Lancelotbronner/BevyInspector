//
//  GameUI.swift
//  Bevy
//
//  Created by Christophe Bronner on 2026-01-26.
//

import SwiftUI

@Observable
final class GameModel {
	static let current = GameModel()

	let surface: IOSurface
	let layer: CALayer
	let connection: NSXPCConnection

	init() {
		let props: [IOSurfacePropertyKey : Any] = [
			.width: 1024,
			.height: 768,
			.pixelFormat: kCVPixelFormatType_32BGRA,
			.bytesPerElement: 4
		]
		surface = IOSurface(properties: props)!

		layer = CALayer()
		layer.contents = surface

		connection = NSXPCConnection(serviceName: "org.bevy")
		let obj = IOSurfaceCreateXPCObject(surface)
	}
}

struct GameDetail: View {
	var body: some View {
		GameViewport()
	}
}

private struct GameViewport: NSViewRepresentable {
	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		view.layer = GameModel.current.layer
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {

	}
}
