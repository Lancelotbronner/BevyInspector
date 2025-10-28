//
//  BevyRemoteProtocol+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

import SwiftUI
import BevyRemoteProtocol
import OpenRPC

extension EnvironmentValues {
	@Entry var bevy = BevyRemoteClient(client: OpenRPCClient())
}
