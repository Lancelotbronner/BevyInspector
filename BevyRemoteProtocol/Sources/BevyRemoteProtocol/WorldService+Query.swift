//
//  WorldService+Query.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import OpenRPC

public struct Query: Codable, Equatable, LosslessStringConvertible, Sendable {
	public init() {}

	public var data = QueryData()
	public var filter = QueryFilter()
	/// A flag to enable strict mode which will fail if any one of the components is not present or can not be reflected. Defaults to false.
	public var strict = false

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(data, forKey: .data)
		if filter != QueryFilter() {
			try container.encode(filter, forKey: .filter)
		}
		try container.encode(strict, forKey: .strict)
	}
}

public struct QueryData: Codable, Equatable, LosslessStringConvertible, Sendable {
	public init() {}

	/// An array of fully-qualified type names of components to fetch, see below example for a query to list all the type names in your project.
	public var components: [String] = []
	/// An array of fully-qualified type names of components to fetch optionally.
	public var option: [String] = []
	/// Fetch all reflectable components.
	public var all = false
	/// An array of fully-qualified type names of components whose presence will be reported as boolean values.
	public var has: [String] = []

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if !components.isEmpty {
			try container.encode(components, forKey: .components)
		}
		if all {
			try container.encode("all", forKey: .option)
		} else if !option.isEmpty {
			try container.encode(option, forKey: .option)
		}
		if !has.isEmpty {
			try container.encode(has, forKey: .has)
		}
	}
}

public struct QueryFilter: Codable, Equatable, LosslessStringConvertible, Sendable {
	public init() {}

	/// An array of fully-qualified type names of components that must be present on entities in order for them to be included in results.
	public var with: [String] = []
	/// An array of fully-qualified type names of components that must not be present on entities in order for them to be included in results.
	public var without: [String] = []

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if !with.isEmpty {
			try container.encode(with, forKey: .with)
		}
		if !without.isEmpty {
			try container.encode(without, forKey: .without)
		}
	}
}

public struct QueryResult: Codable, Sendable {
	public var rows: [QueryRow] = []
	public var columns: [QueryColumn] = []

	public init() {}

	private func _columns() -> [QueryColumn] {
		var columns = Set<String>()
		columns.reserveCapacity(max(8, rows.count * 2))
		for row in rows {
			row._register(columns: &columns)
		}
		return columns.map(QueryColumn.init)
	}
}

public extension QueryResult {
	@inlinable subscript(entity: Entity) -> QueryRow {
		rows.first { $0.entity == entity } ?? QueryRow(entity: entity)
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		rows = try container.decode([QueryRow].self)
		columns = _columns()
		columns.sort()
	}
}

public struct QueryRow: Codable, Identifiable, Sendable {
	/// The ID of a query-matching entity.
	public var entity: Entity
	/// A map associating each type name from components/option to its value on the matching entity if the component is present.
	public var components: [String: JSON] = [:]
	/// A map associating each type name from has to a boolean value indicating whether or not the entity has that component.
	/// If has was empty or omitted, this key will be omitted in the response.
	public var has: [String: Bool] = [:]

	@usableFromInline init(entity: Entity) {
		self.entity = entity
	}

	func _register(columns: inout Set<String>) {
		columns.formUnion(components.keys)
		columns.formUnion(has.keys)
	}
}

public extension QueryRow {
	@inlinable subscript(column: String) -> JSON? {
		components[column]
	}

	@inlinable subscript(column: QueryColumn) -> JSON? {
		components[column.id]
	}

	@inlinable var columns: [QueryColumn] {
		components.keys.lazy.map(QueryColumn.init).sorted()
	}

	@inlinable var id: Entity { entity }

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.entity = try container.decode(Entity.self, forKey: .entity)
		self.components = try container.decodeIfPresent([String : JSON].self, forKey: .components) ?? [:]
		self.has = try container.decodeIfPresent([String : Bool].self, forKey: .has) ?? [:]
	}
}

public struct QueryColumn: Identifiable, Hashable, Comparable, Codable, Sendable {
	public let id: String

	@inlinable public init(_ id: String) {
		self.id = id
	}

	@inlinable public static func < (lhs: QueryColumn, rhs: QueryColumn) -> Bool {
		lhs.id < rhs.id
	}
}
