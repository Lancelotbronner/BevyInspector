//
//  Error.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-31.
//

public struct BevyError: Codable, Error, Sendable {
	public var code: Int
	public var message: String
}
