//
//  QueryModel.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol

@Observable final class QueryModel {
	public let rows: [QueryRow]
	public let columns: [QueryColumn]
	private let _entities: RangeSet<Int>

	init(_ results: QueryResult, excluding: Set<String> = []) {
		rows = results.rows
		columns = results.columns(excluding: excluding)

		let entities = Set(rows.lazy.map(\.entity))
		let roots = rows.indices.lazy.filter {
			results.rows[$0].ChildOf.map { !entities.contains($0) } ?? true
		}
		_entities = RangeSet(roots, within: rows)
	}

	convenience init(query: Query, using bevy: BevyRemoteClient) async throws {
		var query = query
		QueryTableView.prepare(&query)
		let results = try await bevy.world.query(query)
		self.init(results, excluding: QueryTableView.excluded(with: query))
	}
}

extension QueryModel {
	var entities: AnyRandomAccessCollection<EntityModel> {
		AnyRandomAccessCollection(rows[_entities].lazy
			.map { EntityModel(row: $0, query: self) })
	}

	@inlinable func row(of entity: Entity) -> QueryRow {
		rows.first { $0.entity == entity } ?? QueryRow(entity)
	}

	@inlinable func model(of entity: Entity) -> EntityModel {
		EntityModel(row: row(of: entity), query: self)
	}
}

struct EntityModel: Identifiable {
	let row: QueryRow
	let query: QueryModel
}

extension EntityModel {
	var id: Entity { row.entity }

	var children: AnyRandomAccessCollection<EntityModel>? {
		row.Children?.nilIfEmpty
			.map { AnyRandomAccessCollection($0.lazy
				.map(query.model)) }
	}
}
