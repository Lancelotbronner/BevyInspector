//
//  Components.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-31.
//


public extension QueryColumn {
	static let Name = QueryColumn("bevy_ecs::name::Name")
	static let ChildOf = QueryColumn("bevy_ecs::hierarchy::ChildOf")
	static let Children = QueryColumn("bevy_ecs::hierarchy::Children")
	static let Transform = QueryColumn("bevy_transform::components::transform::Transform")
	static let GlobalTransform = QueryColumn("bevy_transform::components::global_transform::GlobalTransform")
}

public extension EntityComponents {
	var Name: String? {
		value(of: .Name)?.string
	}

	var ChildOf: Entity? {
		value(of: .ChildOf)?.usize
	}

	var Children: [Entity]? {
		(value(of: .Children)?.array ?? [])
			.compactMap(\.usize)
			.map(Entity.init)
	}

	@inlinable func contains(_ column: some CustomStringConvertible) -> Bool {
		components.keys.contains(column.description)
	}

	@inlinable func value(of column: QueryColumn) -> JSON? {
		components[column.description]
	}

	@inlinable func value(of column: String) -> JSON? {
		components[column]
	}

	@inlinable func columns() -> [QueryColumn] {
		components.keys.lazy.map(QueryColumn.init).sorted()
	}
}
