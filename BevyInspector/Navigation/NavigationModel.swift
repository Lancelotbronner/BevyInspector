//
//  NavigationModel.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol

@Observable final class Navigation {
	var tab = NavigationTab.world
	var detail: NavigationDetail?
	var schema: BevyType?
	var query = SavedQuery()
	var entity: QueryRow?
	var resource: String?
	var method: Specification.Method?
	var path: [NavigationDetail] = []
}

enum NavigationTab: Hashable {
	case world, queries, schema, triggers, methods
}

enum NavigationQuery: Hashable {
	case none
}

enum NavigationDetail: Hashable {
	case type(BevyType)
}
