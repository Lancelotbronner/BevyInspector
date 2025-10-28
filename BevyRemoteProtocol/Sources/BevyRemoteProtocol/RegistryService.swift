//
//  RegistryService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import OpenRPC

public struct RegistryService: Sendable {
	public let client: OpenRPCClient

	public init(client: OpenRPCClient) {
		self.client = client
	}
}

public extension RegistryService {
	func schema(
		with_crates: [String] = [],
		without_crates: [String] = [],
		with_components: [String] = [],
		without_components: [String] = [],
	) async throws -> [String: BevySchema] {
		let filter = SchemaFilter(
			with_crates: with_crates,
			without_crates: without_crates,
			type_limit: .init(
				with: with_components,
				without: without_components))
		return try await client.invoke(method: "registry.schema", with: filter)
	}

	private struct SchemaFilter: Codable {
		/// An array of crate names to include in the results.
		/// When empty or omitted, types from all crates will be included.
		var with_crates: [String]?

		/// An array of crate names to exclude from the results.
		/// When empty or omitted, no crates will be excluded.
		var without_crates: [String]?

		/// Additional type constraints.
		var type_limit = TypeLimit()

		struct TypeLimit: Codable {
			/// An array of fully-qualified type names that must be present for a type to be included
			var with: [String]?

			/// An array of fully-qualified type names that must not be present for a type to be excluded
			var without: [String]?
		}
	}
}

public struct BevySchema: Codable, Sendable {
	/// Bevy specific field, short path of the type.
	public var short_path: String?
	/// Bevy specific field, full path of the type.
	public var type_path: String?
	/// Bevy specific field, path of the module that type is part of.
	public var module_path: String?
	/// Bevy specific field, name of the crate that type is part of.
	public var crate_name: String?
	/// Bevy specific field, names of the types that type reflects.
	public var reflect_types: [String]?
	/// Bevy specific field, TypeInfo type mapping.
	public var kind: SchemaKind
	/// Bevy specific field, provided when SchemaKind kind field is equal to SchemaKind::Map.
	///
	/// It contains type info of key of the Map.
	public var key_type: JSON?
	/// Bevy specific field, provided when SchemaKind kind field is equal to SchemaKind::Map.
	///
	/// It contains type info of value of the Map.
	public var value_type: JSON?
	/// The type keyword is fundamental to JSON Schema.
	/// It specifies the data type for a schema.
	public var schema_type: SchemaType?
	/// The behavior of this keyword depends on the presence and annotation results of “properties” and “patternProperties” within the same schema object.
	///
	/// Validation with “additionalProperties” applies only to the child values of instance names that do not appear in the annotation results of either “properties” or “patternProperties”.
	public var additional_properties: Bool?
	/// Validation succeeds if, for each name that appears in both the instance and as a name within this keyword’s value, the child instance for that name successfully validates against the corresponding schema.
	public var properties: [String: JSON]?
	/// An object instance is valid against this keyword if every item in the array is the name of a property in the instance.
	public var required: [String]?
	/// An instance validates successfully against this keyword if it validates successfully against exactly one schema defined by this keyword’s value.
	public var one_of: [JSON]?
	/// Validation succeeds if each element of the instance validates against the schema at the same position, if any. This keyword does not constrain the length of the array. If the array is longer than this keyword’s value, this keyword validates only the prefix of matching length.
	///
	/// This keyword produces an annotation value which is the largest index to which this keyword applied a subschema. The value MAY be a boolean true if a subschema was applied to every index of the instance, such as is produced by the “items” keyword.
	///
	/// This annotation affects the behavior of “items” and “unevaluatedItems”.

	public var prefix_items: [JSON]?
	/// This keyword applies its subschema to all instance elements at indexes greater than the length of the “prefixItems” array in the same schema object, as reported by the annotation result of that “prefixItems” keyword.
	///
	/// If no such annotation result exists, “items” applies its subschema to all instance array elements.
	///
	/// If the “items” subschema is applied to any positions within the instance array, it produces an annotation result of boolean true, indicating that all remaining array elements have been evaluated against this keyword’s subschema.
//	public var items: Bool? JSON?
}

public enum SchemaKind: String, Codable, Sendable {
	case Struct
	case Enum
	case Map
	case Array
	case List
	case Tuple
	case TupleStruct
	case Set
	case Value
}

public enum SchemaType: String, Codable, Sendable {
	case String
	case Float
	case Uint
	case Int
	case Object
	case Array
	case Boolean
	case Set
	case Null
}

public struct BevyPropertySchema: Codable, Sendable {
	public var type: TypeSchema

	public struct TypeSchema: Codable, Sendable {
		public var ref: String

		enum CodingKeys: String, CodingKey {
			case ref = "$ref"
		}
	}
}
