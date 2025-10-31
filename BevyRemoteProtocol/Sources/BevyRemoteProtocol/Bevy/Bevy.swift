//
//  Bevy.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

import OpenRPC

public typealias Entity = UInt

public protocol EntityComponents {
	var components: [String: JSON] { get set }
}
