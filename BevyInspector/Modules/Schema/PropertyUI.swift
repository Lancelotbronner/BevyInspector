//
//  PropertyUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI

struct PropertyLabel: View {
	let data: BevyProperty

	var body: some View {
		LabeledContent {
			NavigationLink(value: NavigationDetail.type(data.type)) {
				TypeLabel(data: data.type)
			}
		} label: {
			HStack(alignment: .firstTextBaseline) {
				Text(data.identifier)
					.font(.headline)
					.monospaced()
				IsRequired(data.required)
			}
		}
	}
}


public struct IsRequired: View {
	public let value: Bool

	public init(_ value: Bool) {
		self.value = value
	}

	public var body: some View {
		if !value {
			Text("optional")
				.foregroundStyle(.secondary)
				.font(.caption2)
				.textCase(.uppercase)
		}
	}
}

