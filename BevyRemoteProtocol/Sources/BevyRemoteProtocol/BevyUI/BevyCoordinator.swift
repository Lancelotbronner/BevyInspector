////
////  BevyCoordinator.swift
////  BevyRemoteProtocol
////
////  Created by Christophe Bronner on 2026-02-24.
////
//
//import MetalKit
//
///// A MetalKit view that hosts the Bevy engine
//class BevyMetalViewCoordinator: NSObject, MTKViewDelegate {
//	var bevyApp: UnsafeMutableRawPointer?
//	var onMessageReceived: (@Sendable (Data) -> Void)?
//
//	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//		guard let app = bevyApp else { return }
//		let scale = Float(size.width / view.bounds.width)
//		bevyEmbeddedIosResize(app, UInt32(size.width), UInt32(size.height), scale)
//	}
//
//	func draw(in view: MTKView) {
//		guard let app = bevyApp else { return }
//		bevyEmbeddedUpdate(app)
//
//		// Poll for messages from Bevy
//		pollBevyMessages()
//	}
//
//	func pollBevyMessages() {
//		guard let app = bevyApp, let callback = onMessageReceived else { return }
//
//		var buffer = [UInt8](repeating: 0, count: 1024)
//		let bytesRead = bevyEmbeddedIosReceiveMessage(app, &buffer, buffer.count)
//
//		if bytesRead > 0 {
//			let data = Data(buffer.prefix(bytesRead))
//			DispatchQueue.main.async {
//				callback(data)
//			}
//		}
//	}
//
//	func setupBevy(metalView: MTKView, size: CGSize, scale: CGFloat) {
//		print("Setting up Bevy with size: \(size), scale: \(scale)")
//
//		// Set the current surface for the callback
//		let viewPtr = Unmanaged.passUnretained(metalView).toOpaque()
//		currentSurface = EmbeddedSurfaceInfo(
//			uiView: viewPtr,
//			width: UInt32(size.width),
//			height: UInt32(size.height),
//			scaleFactor: Float(scale)
//		)
//
//		// Create the app - this will call bevy_embedded_get_surface() during plugin finish()
//		bevyApp = bevyEmbeddedCreateApp()
//
//		// Clear the surface info
//		currentSurface = nil
//
//		print("Bevy app initialized: \(bevyApp != nil)")
//	}
//
//	func handleTouch(phase: UInt8, location: CGPoint, id: UInt64) {
//		guard let app = bevyApp else { return }
//		bevyEmbeddedIosTouchEvent(app, phase, Float(location.x), Float(location.y), id)
//	}
//
//	func sendMessage(_ data: Data) {
//		guard let app = bevyApp else { return }
//		data.withUnsafeBytes { ptr in
//			if let baseAddress = ptr.baseAddress {
//				bevyEmbeddedIosSendMessage(app, baseAddress.assumingMemoryBound(to: UInt8.self), data.count)
//			}
//		}
//	}
//
//	deinit {
//		if let app = bevyApp {
//			bevyEmbeddedDestroy(app)
//		}
//	}
//}
//
