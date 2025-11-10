//
//  Bevy.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

public struct Entity: Codable, Hashable, LosslessStringConvertible, Sendable {
	public var rawValue: UInt64

	public init(rawValue: UInt64) {
		self.rawValue = rawValue
	}
}

public extension Entity {
	var generation: UInt32 { UInt32(rawValue >> 32) }
	var row: UInt32 { ~UInt32(truncatingIfNeeded: rawValue) }

	var description: String { "\(row)v\(generation)" }

	init(_ row: UInt32, v generation: UInt32) {
		rawValue = UInt64(row) << 16 | UInt64(generation)
	}

	init?(_ description: String) {
		let components = description.split(separator: "v", maxSplits: 2)
		guard
			components.count == 2,
			let row = UInt32(components[0]),
			let generation = UInt32(components[1])
		else { return nil }
		self.init(row, v: generation)
	}

	init(from decoder: any Decoder) throws {
		rawValue = try decoder.singleValueContainer().decode(UInt64.self)
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}
}

public protocol EntityComponents {
	var components: [String: JSON] { get set }
}
