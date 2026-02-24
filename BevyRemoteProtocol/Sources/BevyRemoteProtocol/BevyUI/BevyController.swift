////
////  BevyController.swift
////  Bevy
////
////  Created by Christophe Bronner on 2026-02-24.
////
//
//import Foundation
//
///// Public API for controlling a Bevy view
/////
///// This provides a clean, Swift-friendly interface for interacting with Bevy
///// without exposing FFI or coordinator details.
//class BevyViewController {
//	private weak var coordinator: BevyMetalViewCoordinator?
//
//	init(coordinator: BevyMetalViewCoordinator) {
//		self.coordinator = coordinator
//	}
//
//	/// Send a message to Bevy
//	func sendMessage(_ data: Data) {
//		coordinator?.sendMessage(data)
//	}
//
//	/// Send a structured message to Bevy
//	func send<T>(_ value: T) where T: Encodable {
//		guard let data = try? JSONEncoder().encode(value) else { return }
//		sendMessage(data)
//	}
//
//	/// Send raw bytes to Bevy
//	func sendBytes(_ bytes: [UInt8]) {
//		sendMessage(Data(bytes))
//	}
//}
