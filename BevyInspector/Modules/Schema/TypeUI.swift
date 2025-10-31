//
//  TypeUI.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import SwiftData

struct TypeLabel: View {
	let data: BevyType

	var body: some View {
		Text(data.name.isEmpty ? data.identifier : data.name)
			.help(data.identifier)
			.monospaced()
	}
}
