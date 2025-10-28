//
//  WorldService+QueryParser.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

public extension Query {
	init?(_ description: some CustomStringConvertible) {
		guard let query = try? Query(parse: description.description[...]) else { return nil }
		self = query
	}

	var description: String {
		"Query<\(data), \(filter)>"
	}

	init(parse description: Substring) throws(ParseError) {
		var query = description
		query.removeFirst(query.prefix(while: \.isWhitespace).count)

		if query.first == "(" {
			query.removeFirst()
			let startOfData = query.startIndex
			var depth = 1
			while let c = query.first, depth > 0 {
				switch c {
				case "(": depth += 1
				case ")": depth -= 1
				default:
					query.removeFirst()
					continue
				}
			}
			if depth > 0 {
				throw .unterminatedTuple(query.index(before: startOfData))
			}
			query.removeFirst()
			data = try QueryData(parse: query[startOfData..<query.startIndex])
			query.removeFirst(query.prefix(while: \.isWhitespace).count)
		} else if let i = query.firstIndex(of: ",") {
			data = try QueryData(parse: query[..<i])
		}

//		data = try QueryData(parse: query[..<i])
//		query.removeFirst(description.distance(from: query.startIndex, to: i) + 1)
//		filter = try QueryFilter(parse: query)
	}

	enum ParseError: Error {
		case unterminatedTuple(String.Index)
	}
}

public extension QueryData {
	init?(_ description: some CustomStringConvertible) {
		guard let query = try? QueryData(parse: description.description[...]) else { return nil }
		self = query
	}

	var description: String {
		var params = [all ? "EntityRef" : "Entity"]
		params += components.map { "&\($0)" }
		params += option.map { "Option<&\($0)>" }
		return Rust.tuple(params, maxSize: 15)
	}

	init(parse description: Substring) throws(Query.ParseError) {

	}
}

public extension QueryFilter {
	init?(_ description: some CustomStringConvertible) {
		guard let query = try? QueryFilter(parse: description.description[...]) else { return nil }
		self = query
	}

	var description: String {
		var params: [String] = []
		params += with.map { "With<\($0)>" }
		params += without.map { "Without<&\($0)>" }
		return Rust.tuple(params, maxSize: 15)
	}

	init(parse description: Substring) throws(Query.ParseError) {

	}
}
