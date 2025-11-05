use anyhow::{anyhow, Result as AnyhowResult};
use bevy_ecs::event::EventKey;
use bevy_ecs::prelude::*;
use bevy_reflect::{TypeRegistration, TypeRegistry};
use bevy_remote::{error_codes, BrpError, BrpResult};
use bevy_remote::builtin_methods::{BrpGetComponentsParams, BrpGetComponentsResponse};
use serde_json::Value;
use serde::{Deserialize, Serialize};

#[derive(Copy, Clone)]
pub enum InspectorMethod {
    TriggerEvent
}

impl InspectorMethod {
    pub fn handler(self) -> fn(In<Option<Value>>, &mut World) -> BrpResult {
        match self {
            InspectorMethod::TriggerEvent => trigger_event,
        }
    }
}

impl Into<String> for InspectorMethod {
    fn into(self) -> String {
        match self {
            InspectorMethod::TriggerEvent => "inspector.trigger_event".to_string(),
        }
    }
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
struct BrpTriggerEventParams {
    pub event: String,
    pub payload: Option<Value>,
}

fn trigger_event(In(params): In<Option<Value>>, world: &mut World) -> BrpResult {
    let BrpTriggerEventParams { event, payload } = parse_some(params)?;

    let app_type_registry = world.resource::<AppTypeRegistry>();
    let type_registry = *app_type_registry.read();
    let event_key = format!("bevy_ecs::event::EventWrapperComponent<{event}>");
    let registration = get_component_type_registration(&type_registry, &event_key[..]);

    let response =
        reflect_components_to_response(components, strict, entity, entity_ref, &type_registry)?;
    serde_json::to_value(response).map_err(BrpError::internal)
}

fn get_component_type_registration<'r>(
    type_registry: &'r TypeRegistry,
    component_path: &str,
) -> AnyhowResult<&'r TypeRegistration> {
    type_registry
        .get_with_type_path(component_path)
        .ok_or_else(|| anyhow!("Unknown component type: `{}`", component_path))
}

/// A helper function used to parse a `serde_json::Value`.
fn parse<T: for<'de> Deserialize<'de>>(value: Value) -> std::result::Result<T, BrpError> {
    serde_json::from_value(value).map_err(|err| BrpError {
        code: error_codes::INVALID_PARAMS,
        message: err.to_string(),
        data: None,
    })
}

/// A helper function used to parse a `serde_json::Value` wrapped in an `Option`.
fn parse_some<T: for<'de> Deserialize<'de>>(value: Option<Value>) -> std::result::Result<T, BrpError> {
    match value {
        Some(value) => parse(value),
        None => Err(BrpError {
            code: error_codes::INVALID_PARAMS,
            message: String::from("Params not provided"),
            data: None,
        }),
    }
}
