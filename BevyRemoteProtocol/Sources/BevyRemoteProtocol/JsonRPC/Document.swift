//
//  Document.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

public struct Specification: Codable {
	public var openrpc: String
	public var info: Info
	public var servers: [Server]
	public var methods: [Method]
	public var components: Components
	public var externalDocs: ExternalDocs

	public struct Info: Codable {
		public var title: String
		public var version: String
	}

	public struct Server: Codable {
		public var name: String
		public var url: String
	}

	public struct Method: Codable, Hashable, Identifiable, Sendable {
		public var name: String
		public var params: [Parameter]

		public var id: String { name }
	}

	public struct Parameter: Codable, Hashable, Sendable {

	}

	public struct Components: Codable {
		public var schemas: [String: JSON] = [:]
	}

	public struct ExternalDocs: Codable {

	}
}

extension Specification {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		openrpc = try container.decode(String.self, forKey: .openrpc)
		info = try container.decode(Info.self, forKey: .info)
		servers = try container.decodeIfPresent([Server].self, forKey: .servers) ?? []
		methods = try container.decodeIfPresent([Method].self, forKey: .methods) ?? []
		components = try container.decodeIfPresent(Components.self, forKey: .components) ?? Components()
		externalDocs = try container.decodeIfPresent(ExternalDocs.self, forKey: .externalDocs) ?? ExternalDocs()
	}
}
