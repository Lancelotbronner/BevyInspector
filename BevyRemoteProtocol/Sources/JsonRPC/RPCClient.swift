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
	func invoke<Parameters: Encodable, Result: Decodable>(
		method: String,
		with params: Parameters,
		as _: Result.Type = Result.self
	) async throws -> Result {
		let body = try encoder.encode(Request(method: method, id: 0, params: params))
		var request = request
		request.httpBody = body
		let (data, _) = try await session.data(for: request)
		if let error = try? decoder.decode(ErrorResponse.self, from: data) {
			throw error.error
		}
		let response = try decoder.decode(Response<Int, Result>.self, from: data)
		return response.result
	}

	func stream<Parameters: Encodable, Event: Decodable & Sendable>(
		method: String,
		with params: Parameters,
		as _: Event.Type = Event.self
	) async throws -> AsyncThrowingStream<Event, Error> {
		let body = try encoder.encode(Request(method: method, id: 0, params: params))
		var request = request
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("text/event-stream; charset=utf-8", forHTTPHeaderField: "Accept")
		request.setValue("keep-alive", forHTTPHeaderField: "Connection")
		request.httpBody = body

		let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
		try Task.checkCancellation()

		guard
			let httpResponse = response as? HTTPURLResponse,
			(200...299).contains(httpResponse.statusCode)
		else { throw Failure(code: 0, message: "HTTP failed") }

		return AsyncThrowingStream(Event.self, bufferingPolicy: .bufferingNewest(3)) { continuation in
			let task = Task {
				for try await line in asyncBytes.lines {
					try Task.checkCancellation()

					guard line.hasPrefix("data: "),
						  let data = line.dropFirst(6).data(using: .utf8)
					else {
						// Seems like we got a partial event or one that doesn't start with
						// `data: `. No big deal. Just continue to the next event in the stream.
						continue
					}

					do {
						let response = try JSONDecoder().decode(Response<Int, Event>.self, from: data)
						continuation.yield(with: .success(response.result))
					} catch {
						continuation.finish(throwing: error)
					}
				}

				continuation.finish()
			}

			continuation.onTermination = { [task] _ in
				task.cancel()
			}
		}
	}
}

public struct Empty: Codable, Sendable {
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

private struct ErrorResponse: Decodable {
	var error: Failure
}

public struct Failure: Decodable, Error, Sendable {
	public var code: Int
	public var message: String
}
