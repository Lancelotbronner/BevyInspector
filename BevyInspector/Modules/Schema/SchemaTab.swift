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
	@Environment(NavigationModel.self) private var navigation
	@Environment(SchemaUpdateModel.self) private var schema

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
	@Environment(NavigationModel.self) private var navigation

	@State private var search = ""
	@State private var reflects: Set<BevyReflect> = []

	var body: some View {
		List(selection: Bindable(navigation).schema) {
			WithQuery(descriptor) {
				ForEach($0) { type in
					NavigationLink(value: type) {
						TypeLabel(data: type)
					}
				}
			}
			.listRowSeparator(.hidden)
		}
		.frame(minWidth: 300)
		.searchable(text: $search)
		.toolbar {
			ReflectPicker(selection: $reflects)
		}
	}

	private var descriptor: FetchDescriptor<BevyType> {
		var descriptor = FetchDescriptor<BevyType>()
		var predicate: Predicate<BevyType>?
		if !search.isEmpty {
			predicate = #Predicate<BevyType> { $0.identifier.localizedStandardContains(search) }
		}
		if !reflects.isEmpty {
			let ids = Array(reflects.lazy.flatMap(\.types).map(\.persistentModelID))
			let tmp = #Predicate<BevyType> {
				ids.contains($0.persistentModelID)
			}
			predicate = predicate.map { accumulated in
				#Predicate<BevyType> { accumulated.evaluate($0) && tmp.evaluate($0) }
			} ?? tmp
		}
		descriptor.predicate = predicate
		descriptor.sortBy = [SortDescriptor(\.identifier)]
		return descriptor
	}
}

private struct ReflectPicker: View {
	@Query private var reflects: [BevyReflect]
	@Binding var selection: Set<BevyReflect>

	var body: some View {
		Menu("Reflect") {
			ForEach(reflects) { reflect in
				Toggle(isOn: $selection[reflect]) {
					Text(reflect.identifier)
						.monospaced()
				}
			}
		}
		.toggleStyle(.checkbox)
	}
}

#Preview(traits: .common) {
	SchemaTab()
}
