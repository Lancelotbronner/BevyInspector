//
//  DiagnosticMessage.swift
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-05-27.
//

public struct DiagnosticMessage: Codable {
	/* Type of this message */
	// "$message_type": "diagnostic",

	/// The primary message.
	public var message: String
	/// The diagnostic code. Some messages may set this value to null.
	public var code: DiagnosticCode?
	/// The severity of the diagnostic.
	/// Values may be:
	/// - "error": A fatal error that prevents compilation.
	/// - "warning": A possible error or concern.
	/// - "note": Additional information or context about the diagnostic.
	/// - "help": A suggestion on how to resolve the diagnostic.
	/// - "failure-note": A note attached to the message for further information.
	/// - "error: internal compiler error": Indicates a bug within the compiler.
	public var level: String
	/// An array of source code locations to point out specific details about where the diagnostic originates from.
	/// This may be empty, for example for some global messages, or child messages attached to a parent.
	///
	/// Character offsets are offsets of Unicode Scalar Values.
	public var spans: [DiagnosticSpan]
	/// Array of attached diagnostic messages.
	/// This is an array of objects using the same format as the parent message.
	/// Children are not nested (children do not themselves contain "children" definitions).
	public var children: [DiagnosticMessage]?
	/// Optional string of the rendered version of the diagnostic as displayed by rustc.
	/// Note that this may be influenced by the `--json` flag.
	public var rendered: String?
}

public struct DiagnosticSpan: Codable {
	/// The file where the span is located.
	///
	/// Note that this path may not exist. For example, if the path points to the standard library, and the rust src is not available in the sysroot, then it may point to a nonexistent file.
	///
	/// Beware that this may also point to the source of an external crate.
	public var file_name: String
	/// The byte offset where the span starts (0-based, inclusive).
	public var byte_start: Int
	/// The byte offset where the span ends (0-based, exclusive).
	public var byte_end: Int
	/// The first line number of the span (1-based, inclusive).
	public var line_start: Int
	/// The last line number of the span (1-based, inclusive).
	public var line_end: Int
	/// The first character offset of the line_start (1-based, inclusive).
	public var column_start: Int
	/// The last character offset of the line_end (1-based, exclusive).
	public var column_end: Int
	/**
	 Whether or not this is the "primary" span.

		This indicates that this span is the focal point of the
		diagnostic.

		There are rare cases where multiple spans may be marked as
		primary. For example, "immutable borrow occurs here" and
		"mutable borrow ends here" can be two separate primary spans.

		The top (parent) message should always have at least one
		primary span, unless it has zero spans. Child messages may have
		zero or more primary spans.
	 */
	public var is_primary: Bool
	/**
	 An array of objects showing the original source code for this
		span. This shows the entire lines of text where the span is
		located. A span across multiple lines will have a separate
		value for each line.
	 */
	public var text: [DiagnosticText]
	/// An optional message to display at this span location.
	/// This is typically null for primary spans.
	public var label: String?
	/// An optional string of a suggested replacement for this span to solve the issue.
	/// Tools may try to replace the contents of the span with this text.
	public var suggested_replacement: String?
	/**
	 An optional string that indicates the confidence of the
		"suggested_replacement". Tools may use this value to determine
		whether or not suggestions should be automatically applied.

		Possible values may be:
		- "MachineApplicable": The suggestion is definitely what the
		  user intended. This suggestion should be automatically
		  applied.
		- "MaybeIncorrect": The suggestion may be what the user
		  intended, but it is uncertain. The suggestion should result
		  in valid Rust code if it is applied.
		- "HasPlaceholders": The suggestion contains placeholders like
		  `(...)`. The suggestion cannot be applied automatically
		  because it will not result in valid Rust code. The user will
		  need to fill in the placeholders.
		- "Unspecified": The applicability of the suggestion is unknown.
	 */
	public var suggestion_applicability: String?
	/**
	 An optional object indicating the expansion of a macro within
		this span.

		If a message occurs within a macro invocation, this object will
		provide details of where within the macro expansion the message
		is located.
	 */
	public var expansion: DiagnosticExpansion?
}

public final class DiagnosticExpansion: Codable {
	/// The span of the macro invocation.
	public var span: DiagnosticSpan
	/// Name of the macro, such as "foo!" or "#[derive(Eq)]".
	public var macro_decl_name: String
	/// Optional span where the relevant part of the macro is defined.
	public var def_site_span: DiagnosticSpan?
}

public struct DiagnosticText: Codable {
	/// The entire line of the original source code.
	public var text: String
	/// The first character offset of the line of where the span covers this line (1-based, inclusive).
	public var highlight_start: Int
	/// The last character offset of the line of where the span covers this line (1-based, exclusive).
	public var highlight_end: Int
}

public struct DiagnosticCode: Codable {
	/// A unique string identifying which diagnostic triggered.
	public var code: String
	/// An optional string explaining more detail about the diagnostic code.
	public var explanation: String?
}
