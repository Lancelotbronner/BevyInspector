//
//  Bevy+Components.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-30.
//

import RealityKit
import Spatial

public struct GlobalTransformComponent: Codable, Sendable {
	public var rawValue: AffineTransform3DFloat

	public init() {
		rawValue = .init()
	}

	public init(from decoder: any Decoder) throws {
		var container = try decoder.unkeyedContainer()
		let x1 = try container.decode(Float.self)
		let y1 = try container.decode(Float.self)
		let z1 = try container.decode(Float.self)
		let x2 = try container.decode(Float.self)
		let y2 = try container.decode(Float.self)
		let z2 = try container.decode(Float.self)
		let x3 = try container.decode(Float.self)
		let y3 = try container.decode(Float.self)
		let z3 = try container.decode(Float.self)
		let x4 = try container.decode(Float.self)
		let y4 = try container.decode(Float.self)
		let z4 = try container.decode(Float.self)
		rawValue = AffineTransform3DFloat(matrix: simd_float4x3(SIMD3(x1, y1, z1), SIMD3(x2, y2, z2), SIMD3(x3, y3, z3), SIMD3(x4, y4, z4)))
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.unkeyedContainer()
		let columns = rawValue.matrix.columns
		try container.encode(columns.0.x)
		try container.encode(columns.0.y)
		try container.encode(columns.0.z)
		try container.encode(columns.1.x)
		try container.encode(columns.1.y)
		try container.encode(columns.1.z)
		try container.encode(columns.2.x)
		try container.encode(columns.2.y)
		try container.encode(columns.2.z)
		try container.encode(columns.3.x)
		try container.encode(columns.3.y)
		try container.encode(columns.3.z)
	}
}

public struct VideoModeComponent: Codable, Sendable {
	public var physical_size = SIMD2<UInt32>.zero
	public var refresh_rate_millihertz: UInt32 = 0
	public var bit_depth: UInt16 = 0

	public init() {}
}
