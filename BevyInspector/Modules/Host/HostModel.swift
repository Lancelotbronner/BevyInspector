//
//  HostModel.swift
//  Bevy
//
//  Created by Christophe Bronner on 2026-02-24.
//

import SwiftUI
import XPC
import BevyXPC

@Observable
final class HostModel {
	private var session: XPCSession!
	private var texture: (any MTLTexture)?
	private var isTextureRequested = false
	private(set) var renderer: MTKGameViewport!

	init() throws {
		renderer = MTKGameViewport(for: self)
		session = try XPCSession(xpcService: XPCHostServiceName) { [weak self] (message: XPCReceivedMessage) in
			do {
				let reply = try message.decode(as: XPCHostReply.self)
				return self?.respond(to: reply)
			} catch {
				print(error)
				return nil
			}
		}
	}

	private func send(_ message: XPCHostMessage) {
		do {
			try session.send(message)
		} catch {
			print(error)
		}
	}

	private func respond(to message: XPCHostReply) -> (any Encodable)? {
		switch message {
		case let .sharedTexture(handle):
			texture = handle.map(\.wrappedValue).flatMap {
				$0.device.makeSharedTexture(handle: $0)
			}
			return nil
		}
	}
}

extension HostModel {
	var sharedTexture: (any MTLTexture)? {
		if !isTextureRequested {
			send(.requestSharedTexture)
		}
		return texture
	}
}
