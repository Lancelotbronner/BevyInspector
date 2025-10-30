//
//  SwiftUI+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import SwiftUI

func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
	Binding<T> { lhs.wrappedValue ?? rhs } set: { lhs.wrappedValue = $0 }
}

extension Label where Icon == Text {
	init(offset: Int, @ViewBuilder title: () -> Title) {
		self.init { title() } icon: {
			Text(offset.description)
				.foregroundStyle(.secondary)
				.monospaced()
		}
	}
}
