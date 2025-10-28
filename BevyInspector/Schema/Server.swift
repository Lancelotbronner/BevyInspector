//
//  Server.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftData

@Model final class Server {
	public init() {}

	public var address = "127.0.0.1"
	public var port = 15702

	public var main = false
}
