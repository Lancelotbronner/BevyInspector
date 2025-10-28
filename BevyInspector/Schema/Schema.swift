//
//  Schema.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftData

extension Array<PersistentModel.Type> {
	static let project: Self = [
		Server.self,
		BevyType.self,
		BevyProperty.self,
	]
}

extension Schema {
	static let project = Schema(.project)
}

extension ModelConfiguration {
	static let project = ModelConfiguration(schema: .project)
}

extension ModelContainer {
	static let preview = try! ModelContainer(for: .project, configurations: .project.preview)
}
