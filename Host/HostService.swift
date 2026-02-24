//
//  EditorService.swift
//  Bevy
//
//  Created by Christophe Bronner on 2026-01-26.
//

import Foundation
import MetalKit
import BevyXPC

extension XPCListener {
	static let bevy = try! XPCListener(service: XPCHostServiceName) { request in
		request.accept(XPCHostService.init)
	 }
}

final class XPCHostService: XPCPeerHandler {
	let session: XPCSession
	let device: MTLDevice
	let shared: MTLSharedTextureHandle?

	init(_ session: XPCSession) {
		self.session = session
		guard let device = MTLCreateSystemDefaultDevice() else {
			fatalError("Metal isn't supported on this system")
		}
		self.device = device

		// Create shared rendering texture
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(
			pixelFormat: CAMetalLayer().pixelFormat,
			width: 400, height: 300, mipmapped: false)
		descriptor.storageMode = .private
		shared = device
			.makeSharedTexture(descriptor: descriptor)?
			.makeSharedTextureHandle()
	}

	private func handle(_ message: XPCHostMessage) -> XPCHostReply? {
		print(session, message)
		switch message {
		case .requestSharedTexture:
			return .sharedTexture(shared.map(CodableViaNSCoding.init))
		}
	}

	func handleIncomingRequest(_ message: XPCReceivedMessage) -> (any Encodable)? {
		do {
			return handle(try message.decode())
		} catch {
			return nil
		}
	}

	func handleCancellation(error: XPCRichError) {
		print(error)
	}
}
