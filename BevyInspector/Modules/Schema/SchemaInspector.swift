//
//  SchemaInspector.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC

struct SchemaInspector: View {
	let schema: BevySchema

	var body: some View {
		if let short_path = schema.short_path {
			LabeledContent("Short Path", value: short_path)
		}
		if let type_path = schema.type_path {
			LabeledContent("Type Path", value: type_path)
		}
		if let module_path = schema.module_path {
			LabeledContent("Module Path", value: module_path)
		}
		if let crate_name = schema.crate_name {
			LabeledContent("Crate", value: crate_name)
		}
		LabeledContent("Kind", value: "\(schema.kind)")
		if let key_type = schema.key_type {
			LabeledContent("Key", value: "\(key_type)")
		}
		if let value_type = schema.value_type {
			LabeledContent("Value", value: "\(value_type)")
		}
		if let schema_type = schema.schema_type {
			LabeledContent("Type", value: "\(schema_type)")
		}
		if let additional_properties = schema.additional_properties {
			LabeledContent("Additional Properties", value: additional_properties ? "True" : "False")
		}

		if let reflect_types = schema.reflect_types {
			LabeledContent("Reflect Types") {
				VStack(alignment: .leading) {
					ForEach(Array(reflect_types.indices), id: \.self) { i in
						Text(reflect_types[i])
					}
				}
			}
		}
		if let properties = schema.properties {
			Section("Properties") {
				ForEach(properties.keys.sorted(), id: \.self) { key in
					PropertySchemaCell(
						key: key,
						property: properties[key]!,
						required: schema.required?.contains(key) ?? false)
				}
			}
		}
		if let one_of = schema.one_of {
			LabeledContent("One Of") {
				VStack(alignment: .leading) {
					ForEach(Array(one_of.indices), id: \.self) { i in
						Text(one_of[i].description)
					}
				}
			}
		}
		if let prefix_items = schema.prefix_items {
			LabeledContent("Prefix Items") {
				VStack(alignment: .leading) {
					ForEach(Array(prefix_items.indices), id: \.self) { i in
						Text(prefix_items[i].description)
					}
				}
			}
		}
		//TODO: items
	}
}
