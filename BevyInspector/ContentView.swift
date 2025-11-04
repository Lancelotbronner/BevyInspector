//
//  ContentView.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import BevyRemoteProtocol

struct ContentView: View {
	@State private var navigation = Navigation()
	@State private var schema = SchemaUpdateModel()

	var body: some View {
		NavigationView()
			.environment(navigation)
			.environment(schema)
	}
}

#Preview {
	ContentView()
		.modelContainer(.preview)
}
