//
//  RPCClient.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import Foundation

public final class OpenRPCClient: Sendable {
	public let session: URLSession
	public let decoder: JSONDecoder
	public let encoder: JSONEncoder
	public let request: URLRequest

	public struct Configuration {
		public var session = URLSession.shared
		public var decoder = JSONDecoder()
		public var encoder = JSONEncoder()
		public var request = URLRequest(url: {
			var components = URLComponents()
			components.scheme = "http"
			components.host = "127.0.0.1"
			components.port = 15702
			return components.url!
		}())

		public init() {}
	}

	public init(configuration: Configuration = Configuration()) {
		session = configuration.session
		encoder = configuration.encoder
		decoder = configuration.decoder
		var request = configuration.request
		request.httpMethod = "POST"
		self.request = request
	}
}

public extension OpenRPCClient {
	func invoke<Parameters: Encodable, Result: Decodable>(method: String, with params: Parameters, as _: Result.Type = Result.self) async throws -> Result {
		let body = try encoder.encode(Request(method: method, id: 0, params: params))
		var request = request
		request.httpBody = body
		let (data, _) = try await session.data(for: request)
		print("\n\n\(String(data: data, encoding: .utf8)?.prefix(8192) ?? "")\n\n")
		let response = try decoder.decode(Response<Int, Result>.self, from: data)
		return response.result
	}
}

public struct Empty: Codable {
	public init() {}
}

private struct Request<ID: Codable, Parameters: Encodable>: Encodable {
	public let jsonrpc = "2.0"
	public var method: String
	public var id: ID
	public var params: Parameters
}

private struct Response<ID: Codable, Result: Decodable>: Decodable {
	public var jsonrpc: String
	public var id: ID
	public var result: Result
}
