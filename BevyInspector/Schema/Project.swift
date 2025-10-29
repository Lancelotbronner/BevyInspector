//
//  Project.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftData
import BevyRemoteProtocol
import Foundation

@Model final class Server {
	public init() {}

	public var address = "127.0.0.1"
	public var port = 15702

	public var main = false
}

@Model final class SavedQuery {
	public init() {}

	private var _name: String?
	private(set) var rust = ""
	private var _query: Data?

	var text = ""

	public var name: String {
		get { _name ?? rust }
		set { _name = newValue }
	}

	public var query: Query {
		get { _query.map { try! JSONDecoder().decode(Query.self, from: $0) } ?? Query() }
		set {
			_query = try! JSONEncoder().encode(newValue)
			rust = newValue.description
		}
	}

	func parse() {
		var query = Query()
		if text == "*" {
			query.data.all = true
		} else {
			query.data.components = text.split(separator: ",").map(String.init)
		}
		self.query = query
	}
}
