//
//  Bevy.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

public struct Entity: Identifiable, RawRepresentable, Hashable, Codable, Sendable {
	public let rawValue: Int

	@inlinable public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	@inlinable public var id: Self { self }

	@inlinable public init(from decoder: any Decoder) throws {
		rawValue = try decoder.singleValueContainer().decode(Int.self)
	}

	@inlinable public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}
}

public extension QueryColumn {
	static let name = QueryColumn("bevy_ecs::name::Name")
}

public extension QueryRow {
	var name: String? {
		try? self[.name]?.asString
	}
}
