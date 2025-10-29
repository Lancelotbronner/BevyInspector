//
//  Json.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import Foundation

public enum JSON: Hashable, Codable, Sendable {
	case string(String)
	case integer(Int)
	case number(Double)
	case boolean(Bool)
	case undefined
	case null
	case array([JSON])
	case object([String: JSON])
}

public extension JSON {
	func decode<T: Decodable>(as type: T.Type = T.self) throws -> T {
		let data = try JSONEncoder().encode(self)
		let result = try JSONDecoder().decode(T.self, from: data)
		return result
	}

	var description: String {
		switch self {
		case let .string(value): "\"\(value.replacingOccurrences(of: "\"", with: "\\\""))\""
		case let .integer(value): value.description
		case let .number(value): value.description
		case let .boolean(value): value.description
		case .null: "null"
		case .undefined: "undefined"
		case let .object(value): "{\(value.lazy.map { "\($0.key): \($0.value.description)" }.joined(separator: ", ") )}"
		case let .array(value): "[\(value.lazy.map(\.description).joined(separator: ", "))]"
		}
	}

	func description(depth: Int = 0) -> String {
		switch self {
		case let .object(value):
			let padding = String(repeating: "\t", count: depth)
			return "{\n\(value.lazy.map { "\(padding)\($0.key): \($0.value.description)" }.joined(separator: ", ") )\n}"
		case let .array(value):
			let padding = String(repeating: "\t", count: depth)
			return"[\n\(value.lazy.map { "\(padding)\($0.description)" }.joined(separator: ", "))\n]"
		default:
			return description
		}
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let stringValue = try? container.decode(String.self) {
			self = .string(stringValue)
		} else if let intValue = try? container.decode(Int.self) {
			self = .integer(intValue)
		} else if let doubleValue = try? container.decode(Double.self) {
			self = .number(doubleValue)
		} else if let booleanValue = try? container.decode(Bool.self) {
			self = .boolean(booleanValue)
		} else if container.decodeNil() {
			self = .null
		} else if let objectValue = try? container.decode([String: JSON].self) {
			self = .object(objectValue)
		} else if let arrayValue = try? container.decode([JSON].self) {
			self = .array(arrayValue)
		} else {
			self = .undefined
		}
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .string(let string): try container.encode(string)
		case .integer(let int): try container.encode(int)
		case .number(let double): try container.encode(double)
		case .boolean(let bool): try container.encode(bool)
		case .undefined: break
		case .null: try container.encodeNil()
		case .array(let array): try container.encode(array)
		case .object(let dictionary): try container.encode(dictionary)
		}
	}
}

public extension JSON {
	var asString: String {
		get throws {
			guard case let .string(value) = self else {
				throw DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: ""))
			}
			return value
		}
	}

	var asInt: Int {
		get throws {
			guard case let .integer(value) = self else {
				throw DecodingError.typeMismatch(Int.self, .init(codingPath: [], debugDescription: ""))
			}
			return value
		}
	}

	var asArray: [JSON] {
		get throws {
			guard case let .array(value) = self else {
				throw DecodingError.typeMismatch([JSON].self, .init(codingPath: [], debugDescription: ""))
			}
			return value
		}
	}
}

public extension Encodable {
	var encoded: JSON {
		get throws {
			let data = try JSONEncoder().encode(self)
			let json = try JSONDecoder().decode(JSON.self, from: data)
			return json
		}
	}
}

public enum AnyCodingKey: CodingKey, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
	case string(String)
	case int(Int)
}

public extension AnyCodingKey {

	init(stringValue: String) {
		self = .string(stringValue)
	}

	var stringValue: String {
		switch self {
		case let .string(value): value
		case let .int(value): value.description
		}
	}

	init(intValue: Int) {
		self = .int(intValue)
	}

	var intValue: Int? {
		switch self {
		case .string: nil
		case let .int(value): value
		}
	}

	init(stringLiteral value: String) {
		self = .string(value)
	}

	init(integerLiteral value: Int) {
		self = .int(value)
	}
}

