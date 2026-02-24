//
//  CodableViaNSCoding.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-02-24.
//

import Foundation

public struct CodableViaNSCoding<T: NSObject & NSCoding>: Codable {
	public let wrappedValue: T

	public init(wrappedValue: T) {
		self.wrappedValue = wrappedValue
	}
}

public extension CodableViaNSCoding {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let data = try container.decode(Data.self)

		let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
		unarchiver.requiresSecureCoding = Self.wrappedValueSupportsSecureCoding

		guard let wrappedValue = T(coder: unarchiver) else {
			let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Failed to unarchive \(T.self)")
			throw DecodingError.typeMismatch(T.self, context)
		}

		unarchiver.finishDecoding()
		self.init(wrappedValue: wrappedValue)
	}

	func encode(to encoder: Encoder) throws {
		let archiver = NSKeyedArchiver(requiringSecureCoding: Self.wrappedValueSupportsSecureCoding)
		wrappedValue.encode(with: archiver)
		archiver.finishEncoding()
		let data = archiver.encodedData

		var container = encoder.singleValueContainer()
		try container.encode(data)
	}

	private static var wrappedValueSupportsSecureCoding: Bool {
		(T.self as? NSSecureCoding.Type)?.supportsSecureCoding ?? false
	}
}
