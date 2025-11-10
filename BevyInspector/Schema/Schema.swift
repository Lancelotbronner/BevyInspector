//
//  Schema.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftData

//TODO: Have everything be in a single large database?
// Use a project entity to separate everything

extension Array<PersistentModel.Type> {
	static let app: Self = [
		Server.self,
		BevyUse.self,
		SavedQuery.self,
	]

	static let project: Self = [
		Server.self,
		SavedQuery.self,
		BevyType.self,
		BevyProperty.self,
		BevyReflect.self,
		BevyUse.self,
	]

	static let session: Self = [
		
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
