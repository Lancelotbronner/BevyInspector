//
//  BevyApp.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import BevyXPC

@main struct BevyApp: App {
	var body: some Scene {
		DocumentGroup(editing: .project, contentType: .project) {
			ContentView()
				.environment(try! HostModel())
		}
	}
}

extension UTType {
	static let project = UTType(exportedAs: "org.bevy.project", conformingTo: .package)
}
