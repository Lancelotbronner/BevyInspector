//
//  Query.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//


public struct Query: Codable, Hashable, LosslessStringConvertible, Sendable {
	public init() {}

	public var data = QueryData()
	public var filter = QueryFilter()
	/// A flag to enable strict mode which will fail if any one of the components is not present or can not be reflected. Defaults to false.
	public var strict = false
}

public extension Query {
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		data = try container.decodeIfPresent(QueryData.self, forKey: .data) ?? QueryData()
		filter = try container.decodeIfPresent(QueryFilter.self, forKey: .filter) ?? QueryFilter()
		strict = try container.decodeIfPresent(Bool.self, forKey: .strict) ?? false
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(data, forKey: .data)
		if filter != QueryFilter() {
			try container.encode(filter, forKey: .filter)
		}
		try container.encode(strict, forKey: .strict)
	}

	private enum CodingKeys: CodingKey {
		case data, filter, strict
	}
}

public struct QueryData: Codable, Hashable, LosslessStringConvertible, Sendable {
	public init() {}

	/// An array of fully-qualified type names of components to fetch, see below example for a query to list all the type names in your project.
	public var components: [String] = []
	/// An array of fully-qualified type names of components to fetch optionally.
	public var option: [String] = []
	/// Fetch all reflectable components.
	public var all = false
	/// An array of fully-qualified type names of components whose presence will be reported as boolean values.
	public var has: [String] = []
}

public extension QueryData {
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		components = try container.decodeIfPresent([String].self, forKey: .components) ?? []
		var isOptionHandled = false
		if let option = try? container.decodeIfPresent(String.self, forKey: .option) {
			isOptionHandled = true
			switch option {
			case "all": all = true
			default:
				let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown option '\(option)', expected 'all' or array of components.")
				throw DecodingError.typeMismatch(QueryData.self, context)
			}
		}
		if !isOptionHandled {
			option = try container.decodeIfPresent([String].self, forKey: .option) ?? []
		}
		has = try container.decodeIfPresent([String].self, forKey: .has) ?? []
	}

	func encode(to encoder: any Encoder) throws {
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

	private enum CodingKeys: CodingKey {
		case components, option, has
	}
}

public struct QueryFilter: Codable, Hashable, LosslessStringConvertible, Sendable {
	public init() {}

	/// An array of fully-qualified type names of components that must be present on entities in order for them to be included in results.
	public var with: [String] = []
	/// An array of fully-qualified type names of components that must not be present on entities in order for them to be included in results.
	public var without: [String] = []
}

public extension QueryFilter {
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		with = try container.decodeIfPresent([String].self, forKey: .with) ?? []
		without = try container.decodeIfPresent([String].self, forKey: .without) ?? []
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if !with.isEmpty {
			try container.encode(with, forKey: .with)
		}
		if !without.isEmpty {
			try container.encode(without, forKey: .without)
		}
	}

	private enum CodingKeys: CodingKey {
		case with, without
	}
}

public struct QueryResult: Codable, Hashable, Sendable {
	public var rows: [QueryRow] = []

	public init() {}
}

public extension QueryResult {
	func row(of entity: Entity) -> QueryRow? {
		rows.first { $0.entity == entity }
	}

	func row(of entity: String) -> QueryRow? {
		rows.first { $0.Name == entity }
	}

	func columns(excluding: Set<String>) -> [QueryColumn] {
		var columns = Set<String>()
		columns.reserveCapacity(max(8, rows.count * 2))
		for row in rows {
			row._register(columns: &columns)
		}
		columns.subtract(excluding)
		return columns.lazy.map(QueryColumn.init).sorted()
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		rows = try container.decode([QueryRow].self)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(unsafeBitCast(self, to: AnyObject.self)))
	}

	static func == (lhs: QueryResult, rhs: QueryResult) -> Bool {
		unsafeBitCast(lhs, to: AnyObject.self) === unsafeBitCast(rhs, to: AnyObject.self)
	}
}

public struct QueryRow: Codable, Equatable, Identifiable, EntityComponents, Sendable {
	/// The ID of a query-matching entity.
	public var entity: Entity
	/// A map associating each type name from components/option to its value on the matching entity if the component is present.
	public var components: [String: JSON] = [:]
	/// A map associating each type name from has to a boolean value indicating whether or not the entity has that component.
	/// If has was empty or omitted, this key will be omitted in the response.
	public var has: [String: Bool] = [:]

	public init(_ entity: Entity, components: [String: JSON] = [:], has: [String: Bool] = [:]) {
		self.entity = entity
		self.components = components
		self.has = has
	}

	@usableFromInline init(entity: Entity) {
		self.entity = entity
	}

	func _register(columns: inout Set<String>) {
		columns.formUnion(components.keys)
		columns.formUnion(has.keys)
	}
}

public extension QueryRow {
	@inlinable var id: Entity { entity }

	var columns: [QueryColumn] {
		components.keys.map(QueryColumn.init)
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.entity = try container.decode(Entity.self, forKey: .entity)
		self.components = try container.decodeIfPresent([String : JSON].self, forKey: .components) ?? [:]
		self.has = try container.decodeIfPresent([String : Bool].self, forKey: .has) ?? [:]
	}
}

public struct QueryColumn: Identifiable, Hashable, Comparable, LosslessStringConvertible, Codable, Sendable {
	public let description: String

	@inlinable public init(_ description: String) {
		self.description = description
	}
}

public extension QueryColumn {
	var id: Self { self }

	var name: Substring {
		guard
			let i = description.lastIndex(of: ":").map(description.index(after:)),
			i < description.endIndex
		else { return description[...] }
		return description[i...]
	}

	var path: Substring {
		guard let i = description.lastIndex(of: ":") else { return description[...] }
		return description[..<i].dropLast()
	}

	@inlinable static func < (lhs: QueryColumn, rhs: QueryColumn) -> Bool {
		lhs.name < rhs.name
	}
}
