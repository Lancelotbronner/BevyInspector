//
//  CargoMessage.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-05-27.
//

public struct CargoMessage: Codable {
	/// The "reason" indicates the kind of message.
	public var reason: String
	/// The Package ID, a unique identifier for referring to the package.
	public var package_id: String
	/// Absolute path to the package manifest.
	public var manifest_path: String
	/// The Cargo target (lib, bin, example, etc.) that generated the message.
	public var target: TargetMessage
	/// The message emitted by the compiler.
	public var message: CompilerMessage
}

public struct TargetMessage: Codable {
	/// Array of target kinds.
	///
	/// - lib targets list the `crate-type` values from the manifest such as "lib", "rlib", "dylib", "proc-macro", etc. (default ["lib"])
	/// - binary is ["bin"]
	/// - example is ["example"]
	/// - integration test is ["test"]
	/// - benchmark is ["bench"]
	/// - build script is ["custom-build"]
	public var kind: [String]
	/// Array of crate types.
	/// - lib and example libraries list the `crate-type` values from the manifest such as "lib", "rlib", "dylib", "proc-macro", etc. (default ["lib"])
	/// - all other target kinds are ["bin"]
	public var crate_types: [String]
	/// The name of the target. For lib targets, dashes will be replaced with underscores.
	public var name: String
	/// Absolute path to the root source file of the target.
	public var src_path: String
	/// The Rust edition of the target. Defaults to the package edition.
	public var edition: String
	/// Array of required features.
	/// This property is not included if no required features are set.
	public var required_features: [String]?
	/// Whether the target should be documented by `cargo doc`.
	public var doc: Bool
	/// Whether or not this target has doc tests enabled, and the target is compatible with doc testing.
	public var doctest: Bool
	/// Whether or not this target should be built and run with `--test`
	public var test: Bool

	private enum CodingKeys: String, CodingKey {
		case kind
		case crate_types
		case name
		case src_path
		case edition
		case required_features = "required-features"
		case doc
		case doctest
		case test
	}
}
