//
//  ResourceUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-11-05.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol

struct ResourceForm: View {
	@Query private var types: [BevyType]
	@Binding var data: JSON
	let name: String

	init(data: Binding<JSON>, name: String) {
		_data = data
		self.name = name

		var descriptor = FetchDescriptor<BevyType>()
		descriptor.fetchLimit = 1
		descriptor.predicate = #Predicate<BevyType> {
			$0.identifier == name
		}
		_types = Query(descriptor)
	}

	var body: some View {
		Form {
			Section {
				if let type = types.first {
					ValueEditor(data: $data, type: type)
				} else {
					JsonEditor(data: $data)
				}
			} header: {
				Text(types.first?.name ?? name)
					.monospaced()
			}
		}
	}
}

struct ResourceModel: Identifiable, Hashable {
	let id: String
	let type: BevyType?
}
