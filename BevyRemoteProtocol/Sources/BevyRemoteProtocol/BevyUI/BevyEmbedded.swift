////
////  BevyEmbedded.swift
////  Bevy
////
////  Created by Christophe Bronner on 2026-02-24.
////
//
//// Surface info struct matching Rust
//struct EmbeddedSurfaceInfo {
//	var uiView: UnsafeRawPointer?
//	var width: UInt32
//	var height: UInt32
//	var scaleFactor: Float
//}
//
//// Global storage for the current surface being initialized
//nonisolated(unsafe) var currentSurface: EmbeddedSurfaceInfo?
//
//// Callback that Rust calls to get the surface
//@_silgen_name("bevy_embedded_get_surface")
//func bevyEmbeddedGetSurface(_ out: UnsafeMutablePointer<EmbeddedSurfaceInfo>) {
//	if let surface = currentSurface {
//		out.pointee = surface
//	} else {
//		out.pointee = EmbeddedSurfaceInfo(uiView: nil, width: 0, height: 0, scaleFactor: 1.0)
//	}
//}
//
//// Import FFI functions from the example
//@_silgen_name("bevy_embedded_create_app")
//func bevyEmbeddedCreateApp() -> UnsafeMutableRawPointer?
//
//@_silgen_name("bevy_embedded_update")
//func bevyEmbeddedUpdate(_ app: UnsafeMutableRawPointer)
//
//@_silgen_name("bevy_embedded_destroy")
//func bevyEmbeddedDestroy(_ app: UnsafeMutableRawPointer)
//
//// Import FFI functions from bevy_embedded crate
//@_silgen_name("bevy_embedded_ios_touch_event")
//func bevyEmbeddedIosTouchEvent(_ app: UnsafeMutableRawPointer, _ phase: UInt8, _ x: Float, _ y: Float, _ id: UInt64)
//
//@_silgen_name("bevy_embedded_ios_resize")
//func bevyEmbeddedIosResize(_ app: UnsafeMutableRawPointer, _ width: UInt32, _ height: UInt32, _ scaleFactor: Float)
//
//@_silgen_name("bevy_embedded_ios_send_message")
//func bevyEmbeddedIosSendMessage(_ app: UnsafeMutableRawPointer, _ data: UnsafePointer<UInt8>, _ length: Int)
//
//@_silgen_name("bevy_embedded_ios_receive_message")
//func bevyEmbeddedIosReceiveMessage(_ app: UnsafeMutableRawPointer, _ buffer: UnsafeMutablePointer<UInt8>, _ bufferLen: Int) -> Int
