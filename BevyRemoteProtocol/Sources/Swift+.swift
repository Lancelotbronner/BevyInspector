//
//  Swift+.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

extension Array {
	func chunked(into size: Int) -> [ArraySlice<Element>] {
		var chunks = stride(from: 0, to: count, by: size).map {
			self[$0 ..< Swift.min($0 + size, count)]
		}
		if count % size != 0 {
			chunks.append(self.suffix(count % size))
		}
		return chunks
	}
}
