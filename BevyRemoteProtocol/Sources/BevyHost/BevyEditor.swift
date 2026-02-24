//
//  BevyEditor.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-02-24.
//

import Foundation
import BevyXPC

final class BevyEditor {
	nonisolated(unsafe) static let shared = BevyEditor()

	private let xpc: NSXPCConnection

	private init() {
		xpc = NSXPCConnection(serviceName: "org.bevy.editor")
		xpc.remoteObjectInterface = NSXPCInterface(with: BevyEditorService.self)
		xpc.activate()
		xpc.remoteObjectProxyWithErrorHandler(<#T##handler: (any Error) -> Void##(any Error) -> Void#>)
	}
}

extension BevyEditor {
	func connect() {
		xpc.activate()
	}
}
