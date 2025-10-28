//
//  SwiftData+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import SwiftData

extension ModelConfiguration {
	var preview: ModelConfiguration {
		ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: true, allowsSave: allowsSave, groupContainer: groupContainer, cloudKitDatabase: cloudKitDatabase)
	}
}
