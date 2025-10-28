//
//  SchemaUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC

struct PropertySchemaCell: View {
	let key: String
	let _property: JSON
	let property: Result<BevyPropertySchema, Error>
	let required: Bool

	init(key: String, property: JSON, required: Bool) {
		self.key = key
		_property = property
		self.property = Result { try property.decode() }
		self.required = required
	}

	var body: some View {
		LabeledContent {
			VStack(alignment: .leading) {
				switch property {
				case let .success(success):
					Text(success.type.ref.dropFirst(8))
						.foregroundStyle(.primary)
				case let .failure(failure):
					Text(verbatim: "\(failure.localizedDescription)\n\(failure)")
						.foregroundStyle(.red)
				}
			}
			.monospaced()
		} label: {
			HStack(alignment: .firstTextBaseline) {
				Text(key)
					.font(.headline)
				IsRequired(required)
			}
		}
	}
}
