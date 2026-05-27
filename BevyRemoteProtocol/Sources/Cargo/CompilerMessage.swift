//
//  CompilerMessage.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-05-27.
//

public enum CompilerMessage: Codable {
	case diagnostic(DiagnosticMessage)
}
