use bevy_ecs::prelude::*;
use bevy_ecs::reflect::from_reflect_with_fallback;
use bevy_reflect::erased_serde::__private::serde::de::IntoDeserializer;
use bevy_reflect::serde::TypedReflectDeserializer;
use bevy_reflect::{DynamicStruct, FromType, PartialReflect, Reflect, TypePath, TypeRegistry};
use bevy_remote::schemas::SchemaTypesMetadata;
use bevy_remote::{error_codes, BrpError, BrpResult};
use serde::de::DeserializeSeed;
use serde::{Deserialize, Serialize};
use serde_json::Value;

/*
use bevy_remote_inspector::ReflectEvent;

#[derive(Event, Reflect)]
#[reflect(Event)]
struct MyEvent;

use bevy_remote_inspector::{InspectorMethod, setup_inspector};

RemotePlugin::default().with_method(
    InspectorMethod::TriggerEvent,
    InspectorMethod::TriggerEvent.handler(),
),

.add_systems(Startup, setup_inspector)
 */

pub fn setup_inspector(mut schema: ResMut<SchemaTypesMetadata>) {
    schema.map_type_data::<ReflectEvent>("Event");
}

#[derive(Clone)]
pub struct ReflectEvent {
    trigger: fn(&mut World, &dyn PartialReflect, &TypeRegistry),
}

impl ReflectEvent {
    pub fn trigger(&self, world: &mut World, event: &dyn PartialReflect, registry: &TypeRegistry) {
        (self.trigger)(world, event, registry)
    }
}

impl<'a, E: Reflect + Event + TypePath> FromType<E> for ReflectEvent
where
    <E as Event>::Trigger<'a>: Default,
{
    fn from_type() -> Self {
        ReflectEvent {
            trigger: |world, reflected_event, registry| {
                let event = from_reflect_with_fallback::<E>(reflected_event, world, registry);
                world.trigger(event);
            },
        }
    }
}

#[derive(Copy, Clone)]
pub enum InspectorMethod {
    TriggerEvent,
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

    world.resource_scope(|world, registry: Mut<AppTypeRegistry>| {
        let registry = registry.read();

        let Some(registration) = registry.get_with_type_path(&event) else {
            return Err(BrpError::resource_error(format!(
                "Unknown event type: `{event}`"
            )));
        };
        let Some(reflect_event) = registration.data::<ReflectEvent>() else {
            return Err(BrpError::resource_error(format!(
                "Event `{event}` is not reflectable"
            )));
        };

        if let Some(payload) = payload {
            let payload: Box<dyn PartialReflect> =
                TypedReflectDeserializer::new(registration, &registry)
                    .deserialize(payload.into_deserializer())
                    .map_err(|err| BrpError::resource_error(format!("{event} is invalid: {err}")))?;
            reflect_event.trigger(world, &*payload, &registry);
        } else {
            let payload = DynamicStruct::default();
            reflect_event.trigger(world, &payload, &registry);
        }

        Ok(Value::Null)
    })
}

//FIXME: These are ripped off the bevy_remote codebase

/// A helper function used to parse a `serde_json::Value`.
fn parse<T: for<'de> Deserialize<'de>>(value: Value) -> std::result::Result<T, BrpError> {
    serde_json::from_value(value).map_err(|err| BrpError {
        code: error_codes::INVALID_PARAMS,
        message: err.to_string(),
        data: None,
    })
}

/// A helper function used to parse a `serde_json::Value` wrapped in an `Option`.
fn parse_some<T: for<'de> Deserialize<'de>>(
    value: Option<Value>,
) -> std::result::Result<T, BrpError> {
    match value {
        Some(value) => parse(value),
        None => Err(BrpError {
            code: error_codes::INVALID_PARAMS,
            message: String::from("Params not provided"),
            data: None,
        }),
    }
}
