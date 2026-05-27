//
//  GameUI.swift
//  Bevy
//
//  Created by Christophe Bronner on 2026-01-26.
//

import SwiftUI
import MetalKit

struct GameDetail: View {
	@Environment(HostModel.self) private var host

	var body: some View {
		GameViewport(host: host)
	}
}

private struct GameViewport: NSViewRepresentable {
	let host: HostModel

	func makeNSView(context: Context) -> NSView {
		let view = MTKView()
		view.device = host.renderer.allocator.device
		view.delegate = host.renderer
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {

	}
}

final class MTKGameViewport: NSObject, MTKViewDelegate {
	let host: HostModel
	let commandQueue: MTL4CommandQueue
	let commandBuffer: MTL4CommandBuffer
	let allocator: MTL4CommandAllocator

	init(for host: HostModel) {
		self.host = host
		guard
			let d = MTLCreateSystemDefaultDevice(),
			let queue = d.makeMTL4CommandQueue(),
			let cmdBuffer = d.makeCommandBuffer(),
			let alloc = d.makeCommandAllocator()
		else { fatalError() }
		self.commandQueue = queue
		self.commandBuffer = cmdBuffer
		self.allocator = alloc
		commandBuffer.beginCommandBuffer(allocator: allocator)
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

	}

	func draw(in view: MTKView) {
		guard
			let rpd = view.currentMTL4RenderPassDescriptor,
			let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)
		else { return }

		//TODO: blit

		encoder.endEncoding()
		commandBuffer.endCommandBuffer()
		if let drawable = view.currentDrawable {
			commandQueue.waitForDrawable(drawable)
			commandQueue.commit([commandBuffer])
			commandQueue.signalDrawable(drawable)
			drawable.present()
		}
		commandBuffer.beginCommandBuffer(allocator: allocator)
	}
}

