//
//  SchemaTab.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol

struct SchemaTab: View {
	var body: some View {

	}
}

struct SchemaDetail: View {
	@Environment(Navigation.self) private var navigation
	@Environment(SchemaModel.self) private var schema

	var body: some View {
		VStack {
			if let type = navigation.schema {
				SchemaForm(data: type)
					.navigationDestination(for: BevyType.self) {
						SchemaForm(data: $0)
					}
			} else if let progress = schema.progress {
				ProgressView(progress)
				 .frame(maxWidth: .infinity, maxHeight: .infinity)
				 .padding()
			}
		}
		.toolbar { SchemaToolbar() }
	}
}

struct SchemaList: View {
	@Environment(Navigation.self) private var navigation

	@State private var search = ""

	var body: some View {
		List(selection: Bindable(navigation).schema) {
			ForEachBevyType(search)
		}
		.frame(minWidth: 300)
		.searchable(text: $search)
	}
}

private struct ForEachBevyType: View {
	@Query private var data: [BevyType]

	init(_ search: String) {
		var descriptor = FetchDescriptor<BevyType>()
		if !search.isEmpty {
			descriptor.predicate = #Predicate<BevyType> { $0.identifier.localizedStandardContains(search) }
		}
		descriptor.sortBy = [SortDescriptor(\.identifier)]
		_data = Query(descriptor)
	}

	var body: some View {
		ForEach(data) { type in
			NavigationLink(value: type) {
				TypeLabel(data: type)
			}
		}
	}
}

#Preview(traits: .common) {
	SchemaTab()
}
