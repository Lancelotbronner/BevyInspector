////
////  BevyPlatformView.swift
////  BevyRemoteProtocol
////
////  Created by Christophe Bronner on 2026-02-24.
////
//
//import SwiftUI
//import MetalKit
//
///// SwiftUI wrapper for the Bevy Metal view
//@MainActor
//struct BevyPlatformView {
//	/// Callback for messages received from Bevy
//	var onMessageReceived: (@Sendable (Data) -> Void)?
//
//	/// Binding to control the view (send messages, etc.)
//	@Binding var controller: BevyViewController?
//
//	init(
//		controller: Binding<BevyViewController?> = .constant(nil),
//		onMessageReceived: (@Sendable (Data) -> Void)? = nil
//	) {
//		self._controller = controller
//		self.onMessageReceived = onMessageReceived
//	}
//
//	func makeCoordinator() -> BevyMetalViewCoordinator {
//		let coord = BevyMetalViewCoordinator()
//		coord.onMessageReceived = onMessageReceived
//		DispatchQueue.main.async {
//			// Expose a clean controller interface instead of raw coordinator
//			self.controller = BevyViewController(coordinator: coord)
//		}
//		return coord
//	}
//}
//
//#if canImport(UIKit)
//import UIKit
//
//extension BevyPlatformView: UIViewRepresentable {
//	func makeUIView(context: Context) -> BevyTouchView {
//		let touchView = BevyTouchView()
//		touchView.coordinator = context.coordinator
//
//		let metalView = MTKBevyView(coordinator: context.coordinator)
//
//		// Add metalView as subview of touchView
//		touchView.addSubview(metalView)
//		metalView.translatesAutoresizingMaskIntoConstraints = false
//		NSLayoutConstraint.activate([
//			metalView.topAnchor.constraint(equalTo: touchView.topAnchor),
//			metalView.bottomAnchor.constraint(equalTo: touchView.bottomAnchor),
//			metalView.leadingAnchor.constraint(equalTo: touchView.leadingAnchor),
//			metalView.trailingAnchor.constraint(equalTo: touchView.trailingAnchor)
//		])
//
//		// Initialize Bevy after the view is configured
//		DispatchQueue.main.async {
//			let size = metalView.drawableSize
//			// Get the scale from the drawable size vs bounds
//			let scale = size.width / metalView.bounds.width
//			context.coordinator.setupBevy(metalView: metalView, size: size, scale: scale)
//
//			// Only set delegate after Bevy is initialized
//			metalView.delegate = context.coordinator
//		}
//
//		return touchView
//	}
//
//	func updateUIView(_ uiView: BevyTouchView, context: Context) {
//		// Handle any updates if needed
//	}
//
//	// Touch handling
//	static func handleTouches(_ touches: Set<UITouch>, phase: UInt8, view: UIView, coordinator: BevyMetalViewCoordinator?) {
//		guard let coord = coordinator else { return }
//
//		for touch in touches {
//			let location = touch.location(in: view)
//			coord.handleTouch(phase: phase, location: location, id: UInt64(touch.hash))
//		}
//	}
//}
//
///// A container view that captures touches for the Metal view
//class BevyTouchView: UIView {
//	var coordinator: BevyMetalViewCoordinator?
//
//
//}
//#endif
