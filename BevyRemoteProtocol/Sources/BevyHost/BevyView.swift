//
//  BevyView.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-02-24.
//

import MetalKit

final class MTKBevyView: MTKView {
	init() {
		guard let device = MTLCreateSystemDefaultDevice() else {
			fatalError("Metal is not supported on this device")
		}
		super.init(frame: .zero, device: device)

		preferredFramesPerSecond = 60
		enableSetNeedsDisplay = false
		isPaused = false  // MTKView drives the render loop
		framebufferOnly = true  // Optimize for rendering
		clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)

		let handle = device.makeSharedTexture(descriptor: <#T##MTLTextureDescriptor#>)

		// Configure for embedded usage
#if canImport(UIKit)
		metalView.isMultipleTouchEnabled = true
#endif

		// Initialize Bevy after the view is configured
		DispatchQueue.main.async { [self] in
			let size = drawableSize
			// Get the scale from the drawable size vs bounds
			let scale = size.width / bounds.width
		}
	}

	required init(coder: NSCoder) {
		fatalError()
	}

#if canImport(UIKit)
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		BevyMetalView.handleTouches(touches, phase: 0, view: self, coordinator: coordinator)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		BevyMetalView.handleTouches(touches, phase: 1, view: self, coordinator: coordinator)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		BevyMetalView.handleTouches(touches, phase: 2, view: self, coordinator: coordinator)
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		BevyMetalView.handleTouches(touches, phase: 3, view: self, coordinator: coordinator)
	}
#endif
}
