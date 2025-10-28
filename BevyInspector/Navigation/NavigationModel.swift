//
//  NavigationModel.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI

@Observable final class Navigation {
	var tab = NavigationTab.world
	var detail: NavigationDetail?
	var schema: BevyType?
	var query = NavigationQuery.none
	var path: [NavigationDetail] = []
}

enum NavigationTab: Hashable {
	case world, query, schema, methods
}

enum NavigationQuery: Hashable {
	case none
}

enum NavigationDetail: Hashable {
	case type(BevyType)
}
