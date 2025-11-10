//
//  BevyInspectorApp.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main struct BevyInspectorApp: App {
	var body: some Scene {
		DocumentGroup(editing: .project, contentType: .project) {
			ContentView()
		}
	}
}

extension UTType {
	static let project = UTType(exportedAs: "org.bevy.project", conformingTo: .package)
}
