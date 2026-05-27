//
//  NavigationModel.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol

@Observable final class NavigationModel {
	var tab = NavigationTab.world
	var detail: NavigationDetail?
	var schema: BevyType?
	var query = SavedQuery()
	var entity: QueryRow?
	var resource: String?
	var event: BevyType?
	var method: Specification.Method?
	var path: [NavigationDetail] = []
}

enum NavigationTab: Hashable {
	case world, queries, game, schema, triggers, methods
	case crate(CrateModel)
}

enum NavigationQuery: Hashable {
	case none
}

enum NavigationDetail: Hashable {
	case type(BevyType)
}
