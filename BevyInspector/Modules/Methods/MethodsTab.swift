//
//  MethodsTab.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import OSLog
import BevyRemoteProtocol

struct MethodsTab: View {
	var body: some View {

	}
}

struct MethodsList: View {
	@Environment(Navigation.self) private var navigation
	@Environment(\.bevy) private var bevy
	@State private var specification: Specification?
	@State private var search = ""

	var body: some View {
		List(selection: Bindable(navigation).method) {
			ForEach(methods, id: \.name) { method in
				Text(method.name)
					.tag(method)
					.listRowSeparator(.hidden)
			}
		}
		.monospaced()
		.frame(minWidth: 300)
		.searchable(text: $search)
		.task {
			do {
				print("bevy.rpc.discover")
				specification = try await bevy.rpc.discover()
			} catch {
				Logger.bevy.critical("\(error.localizedDescription)\n\(error)")
			}
		}
	}

	private var methods: [Specification.Method] {
		guard let specification else { return [] }
		guard !search.isEmpty else { return specification.methods }
		return specification.methods.filter {
			$0.name.localizedStandardContains(search)
		}
	}
}

struct MethodsDetail: View {
	@Environment(Navigation.self) private var navigation

	var body: some View {
		if let method = navigation.method {
			Form {
				Section("Method") {
					LabeledContent("Name") {
						Text(method.name)
							.monospaced()
					}
				}
				Section("Parameters") {
					Text("Not supported by \(Text(verbatim: "bevy_remote").monospaced()) yet.")
						.foregroundStyle(.secondary)
				}
			}
			.formStyle(.grouped)
		}
	}
}
