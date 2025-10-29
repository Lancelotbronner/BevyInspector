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
	var path: [NavigationDetail] = []
}

enum NavigationTab: Hashable {
	case world, schema, methods
}

enum NavigationQuery: Hashable {
	case none
}

enum NavigationDetail: Hashable {
	case type(BevyType)
}
