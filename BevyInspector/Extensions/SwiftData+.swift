//
//  SwiftData+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData

extension ModelConfiguration {
	var preview: ModelConfiguration {
		ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: true, allowsSave: allowsSave, groupContainer: groupContainer, cloudKitDatabase: cloudKitDatabase)
	}
}

struct WithQuery<Content: View, Model: PersistentModel>: View {
	@Query var data: [Model]
	let content: ([Model]) -> Content

	init(
		_ descriptor: FetchDescriptor<Model>,
		@ViewBuilder content: @escaping ([Model]) -> Content
	) {
		_data = Query(descriptor)
		self.content = content
	}

	var body: some View {
		content(data)
	}
}
