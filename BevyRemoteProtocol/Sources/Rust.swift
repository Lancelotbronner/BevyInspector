//
//  Rust.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2025-10-28.
//

public enum Rust {
	static func tuple(_ params: [String], maxSize: Int) -> String {
		guard params.count > 1 else { return params.first ?? "()" }
		var params = params
		return tuple(&params, maxSize: maxSize)
	}

	static func tuple(_ params: inout [String], maxSize: Int) -> String {
		guard params.count > 1 else { return params.first ?? "()" }
		while params.count > maxSize {
			let param = params.suffix(maxSize).joined(separator: ", ")
			params.removeLast(maxSize)
			params.append("(\(param))")
		}
		return "(\(params.joined(separator: ", ")))"
	}
}
