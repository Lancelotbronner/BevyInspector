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
	static let Name = QueryColumn("bevy_ecs::name::Name")
	static let ChildOf = QueryColumn("bevy_ecs::hierarchy::ChildOf")
	static let Children = QueryColumn("bevy_ecs::hierarchy::Children")
}

public extension QueryRow {
	var Name: String? {
		try? self.value(of: .Name)?.asString
	}

	var ChildOf: Entity? {
		(try? self.value(of: .ChildOf)?.asInt).map(Entity.init)
	}

	var Children: [Entity]? {
		(try? self.value(of: .Children)?.asArray ?? [])?
			.compactMap { try? $0.asInt }
			.map(Entity.init)
	}
}
