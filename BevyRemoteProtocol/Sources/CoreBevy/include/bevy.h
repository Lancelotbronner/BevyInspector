//
//  bevy.h
//  BevyRemoteProtocol
//
//  Created by Christophe Bronner on 2026-02-24.
//

#include <stdint.h>

/// Configuration passed from the host application to the embedded Bevy app.
///
/// All pointer fields are optional and can be null.
struct bevy_config {
	/// Pointer to the native view (NSView on macOS, UIView on iOS, etc.)
	void const *view;
	/// Width in physical pixels
	uint32_t width;
	/// Height in physical pixels
	uint32_t height;
	/// Scale factor (retina displays have scale > 1.0)
	float scale_factor;
	/// Asset path override (null-terminated C string, or null for default "assets")
	char const *asset_path;
}

/// Set the embedded configuration from the host application.
///
/// This must be called before `bevy_embedded_create_app()`.
///
/// # Safety
///
/// - `config` must be a valid pointer to an `EmbeddedConfig` struct
/// - The `view` pointer in the config must be valid for the lifetime of the Bevy app
/// - The `asset_path` pointer (if not null) must point to a valid null-terminated string
void bevy_set_config(struct bevy_config const *config);
