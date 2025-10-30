//
//  Log.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-30.
//

import OSLog

nonisolated extension Logger {
	static let bevy = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "bevy")
}
