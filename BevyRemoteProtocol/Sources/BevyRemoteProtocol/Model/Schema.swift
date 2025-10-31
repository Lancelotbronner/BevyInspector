//
//  Schema.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-30.
//

import OpenRPC

public struct BevySchema: Codable, Sendable {
	/// Bevy specific field, short path of the type.
	public var shortPath: String?
	/// Bevy specific field, full path of the type.
	public var typePath: String?
	/// Bevy specific field, path of the module that type is part of.
	public var modulePath: String?
	/// Bevy specific field, name of the crate that type is part of.
	public var crateName: String?
	/// Bevy specific field, names of the types that type reflects.
	public var reflectTypes: [String]?
	public var type = SchemaType.Value
}

public extension BevySchema {
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.shortPath = try container.decodeIfPresent(String.self, forKey: .shortPath)
		self.typePath = try container.decodeIfPresent(String.self, forKey: .typePath)
		self.modulePath = try container.decodeIfPresent(String.self, forKey: .modulePath)
		self.crateName = try container.decodeIfPresent(String.self, forKey: .crateName)
		self.reflectTypes = try container.decodeIfPresent([String].self, forKey: .reflectTypes)
		type = try SchemaType(from: decoder)
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(self.shortPath, forKey: .shortPath)
		try container.encodeIfPresent(self.typePath, forKey: .typePath)
		try container.encodeIfPresent(self.modulePath, forKey: .modulePath)
		try container.encodeIfPresent(self.crateName, forKey: .crateName)
		try container.encodeIfPresent(self.reflectTypes, forKey: .reflectTypes)
		try type.encode(to: encoder)
	}

	private enum CodingKeys: CodingKey {
		case shortPath
		case typePath
		case modulePath
		case crateName
		case reflectTypes
		case kind
	}
}

public enum SchemaKind: String, Codable, Hashable, Sendable {
	case Struct, Object, Enum, Map, Array, List, Set, Tuple, TupleStruct, Value
}

public enum SchemaType: Codable, Sendable {
	case Struct(properties: [String: JSON], required: [String], additional: Bool)
	case Enum(variants: [SchemaVariant])
	case Map(key: SchemaReference, value: SchemaReference)
	case Array(SchemaSequence)
	case List(SchemaSequence)
	case Set(SchemaSequence)
	case Tuple(SchemaTuple)
	case TupleStruct(SchemaTuple)
	case Value
	case Ref(identifier: String)
}

public struct SchemaSequence: Codable, Sendable {
	public var items: SchemaReference
}

public struct SchemaTuple: Codable, Sendable {
	public var prefixItems: [SchemaReference]

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		prefixItems = try container.decodeIfPresent([SchemaReference].self, forKey: .prefixItems) ?? []
	}
}

public extension SchemaType {
	var discriminator: SchemaKind {
		switch self {
		case let .Struct(_,_,open): open ? .Object : .Struct
		case .Enum: .Enum
		case .Map: .Map
		case .Array: .Array
		case .List: .List
		case .Set: .Set
		case .Tuple: .Tuple
		case .TupleStruct: .TupleStruct
		case .Value: .Value
		case .Ref: fatalError()
		}
	}

	var asTuple: SchemaTuple? {
		switch self {
		case .Tuple(let tuple), .TupleStruct(let tuple): tuple
		default: nil
		}
	}

	var asSequence: SchemaSequence? {
		switch self {
		case .Array(let v), .List(let v), .Set(let v): v
		default: nil
		}
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
	known:
		if let kind = try container.decodeIfPresent(String.self, forKey: .kind) {
			switch kind {
			case "Struct": self = .Struct(
				properties: try container.decodeIfPresent([String: JSON].self, forKey: .properties) ?? [:],
				required: try container.decodeIfPresent([String].self, forKey: .required) ?? [],
				additional: try container.decodeIfPresent(Bool.self, forKey: .additionalProperties) ?? false)
			case "Map": self = .Map(
				key: try container.decode(SchemaReference.self, forKey: .keyType),
				value: try container.decode(SchemaReference.self, forKey: .valueType))
			case "Enum": self = .Enum(
				variants: try container.decodeIfPresent([SchemaVariant].self, forKey: .oneOf) ?? [])
			case "Array": self = .Array(try SchemaSequence(from: decoder))
			case "List": self = .List(try SchemaSequence(from: decoder))
			case "Set": self = .Set(try SchemaSequence(from: decoder))
			case "Tuple": self = .Tuple(try SchemaTuple(from: decoder))
			case "TupleStruct": self = .TupleStruct(try SchemaTuple(from: decoder))
			case "Value": self = .Value
			case "Ref": break known
			default:
				let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown schema value '\(kind)'")
				throw DecodingError.typeMismatch(SchemaType.self, context)
			}
			return
		}
		if let type = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .type) {
			let ref = try type.decode(String.self, forKey: .ref)
			self = .Ref(identifier: String(ref.dropFirst(8)))
			return
		}
		self = .Value
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(discriminator.rawValue, forKey: .kind)
		switch self {
		case let .Struct(properties, required, additional):
			try container.encode(properties, forKey: .properties)
			try container.encode(required, forKey: .required)
			try container.encode(additional, forKey: .additionalProperties)
		case let .Map(key, value):
			try container.encode(key, forKey: .keyType)
			try container.encode(value, forKey: .valueType)
		case let .Enum(variants):
			try container.encode(variants, forKey: .oneOf)
		case let .Array(sequence), let .List(sequence), let .Set(sequence):
			try container.encode(sequence.items, forKey: .items)
		case let .Tuple(tuple), let .TupleStruct(tuple):
			try container.encode("Tuple", forKey: .kind)
			try container.encode(tuple.prefixItems, forKey: .prefixItems)
		case let .Ref(identifier):
			var type = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .type)
			try type.encode(identifier, forKey: .ref)
		case .Value:
			break
		}
	}

	private enum CodingKeys: String, CodingKey {
		case kind, type, properties, additionalProperties, required, oneOf, prefixItems, items, keyType, valueType
		case ref = "$ref"
	}
}

public struct SchemaVariant: Codable, Sendable {
	public var shortPath: String
	public var typePath: String?
	public var type = SchemaType.Value
}

public extension SchemaVariant {
	init(from decoder: any Decoder) throws {
		let single = try decoder.singleValueContainer()
		if let string = try? single.decode(String.self) {
			shortPath = string
			return
		}
		let container = try decoder.container(keyedBy: CodingKeys.self)
		shortPath = try container.decode(String.self, forKey: .shortPath)
		typePath = try container.decodeIfPresent(String.self, forKey: .typePath)
		type = try SchemaType(from: decoder)
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(shortPath, forKey: .shortPath)
		try container.encodeIfPresent(typePath, forKey: .typePath)
		try type.encode(to: encoder)
	}

	private enum CodingKeys: String, CodingKey {
		case shortPath, typePath, type
	}
}

public enum SchemaItems: Codable, Sendable {
	case boolean(Bool)
	case property(SchemaReference)
}

public extension SchemaItems {
	var property: SchemaReference? {
		switch self {
		case let .property(value): value
		default: nil
		}
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let value = try? container.decode(Bool.self) {
			self = .boolean(value)
		} else {
			self = .property(try container.decode(SchemaReference.self))
		}
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case let .boolean(value): try container.encode(value)
		case let .property(value): try container.encode(value)
		}
	}
}

public struct SchemaReference: Codable, Sendable {
	public var type: TypeSchema

	public var identifier: Substring {
		type.ref.dropFirst(8)
	}

	public struct TypeSchema: Codable, Sendable {
		public var ref: String

		enum CodingKeys: String, CodingKey {
			case ref = "$ref"
		}
	}
}
