//
//  HostModel.swift
//  Bevy
//
//  Created by Christophe Bronner on 2026-02-24.
//

import SwiftUI
import XPC
import BevyXPC

@Observable
final class HostModel {
	private let session: XPCSession

	init() throws {
		session = try XPCSession(xpcService: XPCHostServiceName)
	}
}
