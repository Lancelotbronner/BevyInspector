//
//  HostService.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-02-24.
//

import Foundation
import MetalKit

public let XPCHostServiceName = "org.bevy.editor.host"

public enum XPCHostMessage: Codable {
	case requestSharedTexture
}

public enum XPCHostReply: Codable {
	case sharedTexture(CodableViaNSCoding<MTLSharedTextureHandle>?)
}
