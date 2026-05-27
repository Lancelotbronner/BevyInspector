//
//  CargoMetadata.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-05-27.
//

import Json

public struct CargoMetadata: Codable {
	/// All packages in the workspace.
	///
	/// It also includes all feature-enabled dependencies unless --no-deps is used.
	public var packages: [PackageMetadata]
	/// Array of members of the workspace.
	/// Each entry is the Package ID for the package.
	public var workspace_members: [PackageId]
	/// Array of default members of the workspace.
	/// Each entry is the Package ID for the package.
	public var workspace_default_members: [PackageId]
	/// The resolved dependency graph for the entire workspace.
	/// The enabled features are based on the enabled features for the "current" package.
	///
	/// Inactivated optional dependencies are not listed.
	/// This is null if --no-deps is specified.
	///
	/// By default, this includes all dependencies for all target platforms.
	/// The `--filter-platform` flag may be used to narrow to a specific target triple.
	public var resolve: ResolveMetadata?
	/// The absolute path to the target directory where Cargo places its output.
	public var target_directory: String
	/// The absolute path to the build directory where Cargo places intermediate build artifacts. (unstable)
	public var build_directory: String
	/// The version of the schema for this metadata structure.
	/// This will be changed if incompatible changes are ever made.
	public var version: Int
	/// The absolute path to the root of the workspace.
	public var workspace_root: String
	/// Workspace metadata. This is null if no metadata is specified.
	public var metadata: JSON?
}

public typealias PackageId = String

public struct PackageMetadata: Codable {
	/// The name of the package.
	public var name: String
	/// The version of the package.
	public var version: String
	/// The Package ID for referring to the package within the document and as the `--package` argument to many commands.
	public var id: PackageId
	/// The license value from the manifest, or null.
	public var license: String?
	/// The license-file value from the manifest, or null.
	public var license_file: String?
	/// The description value from the manifest, or null.
	public var description: String?
	/// The source ID of the package, an "opaque" identifier representing where a package is retrieved from.
	///
	/// This is null for path dependencies and workspace members.
	///
	/// For other dependencies, it is a string with the format:
	/// - "registry+URL" for registry-based dependencies.
	///   Example: "registry+https://github.com/rust-lang/crates.io-index"
	/// - "git+URL" for git-based dependencies.
	///   Example: "git+https://github.com/rust-lang/cargo?rev=5e85ba14aaa20f8133863373404cb0af69eeef2c#5e85ba14aaa20f8133863373404cb0af69eeef2c"
	/// - "sparse+URL" for dependencies from a sparse registry
	///   Example: "sparse+https://my-sparse-registry.org"
	///
	/// The value after the `+` is not explicitly defined, and may change between versions of Cargo and may not directly correlate to other things, such as registry definitions in a config file.
	/// New source kinds may be added in the future which will have different `+` prefixed identifiers.
	public var source: String?
	/// Array of dependencies declared in the package's manifest.
	public var dependencies: [DependencyMetadata]
	/// Array of Cargo targets.
	public var targets: [TargetMetadata]
	/// Set of features defined for the package.
	/// Each feature maps to an array of features or dependencies it enables.
	public var features: [String: [String]]
	/// Absolute path to this package's manifest.
	public var manifest_path: String
	/// Package metadata. This is null if no metadata is specified.
	public var metadata: JSON?
	/// List of registries to which this package may be published.
	/// Publishing is unrestricted if null, and forbidden if an empty array.
	public var publish: [String]?
	/// Array of authors from the manifest.
	public var authors: [String]
	/// Array of categories from the manifest.
	public var categories: [String]
	/// Optional string that is the default binary picked by cargo run.
	public var default_run: String?
	/// Optional string that is the minimum supported rust version
	public var rust_version: String?
	/// Array of keywords from the manifest.
	public var keywords: [String]
	/// The readme value from the manifest or null if not specified.
	public var readme: String?
	/// The repository value from the manifest or null if not specified.
	public var repository: String?
	/// The homepage value from the manifest or null if not specified.
	public var homepage: String?
	/// The documentation value from the manifest or null if not specified.
	public var documentation: String?
	/// The default edition of the package.
	/// Note that individual targets may have different editions.
	public var edition: String
	/// Optional string that is the name of a native library the package is linking to.
	public var links: String?
}

public struct DependencyMetadata: Codable {
	/// The name of the dependency.
	public var name: String
	/// The source ID of the dependency. See ``PackageMetadata/source``.
	public var source: String?
	/// The version requirement for the dependency.
	///
	/// Dependencies without a version requirement have a value of `"*"`.
	public var req: String
	/// The dependency kind. `"dev"`, `"build"`, or `null` for a normal dependency.
	public var kind: String?
	/// If the dependency is renamed, this is the new name for the dependency as a string.
	/// null if it is not renamed.
	public var rename: String?
	/// Boolean of whether or not this is an optional dependency.
	public var optional: Bool
	/// Boolean of whether or not default features are enabled.
	public var uses_default_features: Bool
	/// Array of features enabled.
	public var features: [String]
	/// The target platform for the dependency. null if not a target dependency.
	public var target: String?
	/// The file system path for a local path dependency. not present if not a path dependency.
	public var path: String?
	/// A string of the URL of the registry this dependency is from.
	/// If not specified or null, the dependency is from the default registry (crates.io).
	public var registry: String?
	/// (unstable) Boolean flag of whether or not this is a public dependency.
	/// This field is only present when `-Zpublic-dependency` is enabled.
	public var `public`: Bool?
}

public struct TargetMetadata: Codable {
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
	public var types: [String]
	/// The name of the target. For lib targets, dashes will be replaced with underscores.
	public var name: String
	/// Absolute path to the root source file of the target.
	public var path: String
	/// The Rust edition of the target. Defaults to the package edition.
	public var edition: String
	/// Array of required features.
	/// This property is not included if no required features are set.
	public var requiredFeatures: [String]?
	/// Whether the target should be documented by `cargo doc`.
	public var doc: Bool
	/// Whether or not this target has doc tests enabled, and the target is compatible with doc testing.
	public var doctest: Bool
	/// Whether or not this target should be built and run with `--test`
	public var test: Bool

	private enum CodingKeys: String, CodingKey {
		case kind
		case types = "crate_types"
		case name
		case path = "src_path"
		case edition
		case requiredFeatures = "required_features"
		case doc
		case doctest
		case test
	}
}

public struct ResolveMetadata: Codable {
	/// Array of nodes within the dependency graph.
	/// Each node is a package.
	public var nodes: [ResolvedPackageMetadata]
	/// The package in the current working directory (if --manifest-path is not given).
	/// This is null if there is a virtual workspace.
	/// Otherwise it is the Package ID of the package.
	public var root: PackageId?
}

public struct ResolvedPackageMetadata: Codable {
	/// The Package ID of this node.
	public var id: PackageId
	/// The dependencies of this package, an array of Package IDs.
	public var dependencies: [PackageId]
	/// The dependencies of this package.
	/// This is an alternative to ``dependencies`` which contains additional information.
	/// In particular, this handles renamed dependencies.
	public var deps: [ResolvedDependencyMetadata]
	/// Array of features enabled on this package.
	public var features: [String]
}

public struct ResolvedDependencyMetadata: Codable {
	/// The name of the dependency's library target.
	/// If this is a renamed dependency, this is the new name.
	public var name: String
	/// The Package ID of the dependency.
	public var pkg: PackageId
	/// Array of dependency kinds.
	public var dep_kinds: [ResolvedDependencyKind]
}

public struct ResolvedDependencyKind: Codable {
	/// The dependency kind. "dev", "build", or null for a normal dependency.
	public var kind: String?
	/// The target platform for the dependency. null if not a target dependency.
	public var target: String?
}
