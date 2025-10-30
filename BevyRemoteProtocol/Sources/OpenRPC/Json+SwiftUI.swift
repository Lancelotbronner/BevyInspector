//
//  Json+SwiftUI.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-30.
//

#if canImport(SwiftUI)
import SwiftUI

public extension Binding<JSON> {
	subscript<T: Codable & SendableMetatype>(_: T.Type) -> Binding<T?> {
		Binding<T?> {
			wrappedValue[T.self]
		} set: {
			wrappedValue[T.self] = $0
		}
	}
}
#endif
