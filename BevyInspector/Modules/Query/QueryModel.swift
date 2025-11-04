//
//  QueryModel.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol

final class QueryModel: Equatable {
	public let rows: [QueryRow]
	public let columns: [QueryColumn]
	private let _entities: RangeSet<Int>

	init(rows: [QueryRow], columns: [QueryColumn]) {
		self.rows = rows
		self.columns = columns

		let entities = Set(rows.lazy.map(\.entity))
		let roots = rows.indices.lazy.filter {
			rows[$0].ChildOf.map { !entities.contains($0) } ?? true
		}
		_entities = RangeSet(roots, within: rows)
	}

	convenience init(_ results: QueryResult, excluding: Set<String> = []) {
		self.init(rows: results.rows, columns: results.columns(excluding: excluding))
	}

	convenience init(query: Query, using bevy: BevyRemoteClient) async throws {
		var query = query
		QueryTableView.prepare(&query)
		let results = try await bevy.world.query(query)
		self.init(results, excluding: QueryTableView.excluded(with: query))
	}

	static func == (lhs: QueryModel, rhs: QueryModel) -> Bool {
		lhs === rhs
	}
}

extension QueryModel {
	var entities: AnyRandomAccessCollection<QueryRowModel> {
		AnyRandomAccessCollection(rows[_entities].lazy
			.map { QueryRowModel(row: $0, query: self) })
	}

	@inlinable func row(of entity: Entity) -> QueryRow {
		rows.first { $0.entity == entity } ?? QueryRow(entity)
	}

	@inlinable func model(of entity: Entity) -> QueryRowModel {
		QueryRowModel(row: row(of: entity), query: self)
	}
}

struct QueryRowModel: Identifiable {
	let row: QueryRow
	let query: QueryModel
}

extension QueryRowModel {
	var id: Entity { row.entity }

	var children: AnyRandomAccessCollection<QueryRowModel>? {
		row.Children?.nilIfEmpty
			.map { AnyRandomAccessCollection($0.lazy
				.map(query.model)) }
	}
}
