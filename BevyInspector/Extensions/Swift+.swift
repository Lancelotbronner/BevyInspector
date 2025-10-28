//
//  Swift+.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-28.
//

nonisolated extension Sequence {
	func lookup<Key: Hashable>(by key: KeyPath<Element, Key>) -> Dictionary<Key, Element> {
		Dictionary(uniqueKeysWithValues: map { ($0[keyPath: key], $0) })
	}
}

nonisolated extension Collection {
	var single: Element? {
		count == 1 ? first : nil
	}
}
