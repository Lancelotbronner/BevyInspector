# Bevy Inspector

> # Note
> Very WIP

## Overview

An app which uses the [Bevy Remote Protocol](https://docs.rs/bevy_remote/latest/bevy_remote/index.html) to help you debug and develop your games.

Currently only macOS is intented for support but I want to extend this to iPad and iPhone too.

## Current Features

### Project Oriented

This is a document app so you can keep your configuration on a per-workspace level.

### World Tab

Displays the hierarchy of your world and lets you view their components fullscreen.
Will always show all the components of the selected entity.

### Query Tab

Write queries and view the resulting hierarchy in a table.
Select an entity to reveal a component inspector.
Save your queries to the project, allowing quick access to what you care about.

Currently the query format is either `*` or a comma-separated list of full component name.

### Schema Tab

There's a schema tab that lets you look at all the types registered by `bevy`.

This is currently useful to find the full name of a type (such as `bevy_ecs::name::Name`) to use in the Query Tab.

The schema is cached in the project document.
It's also a database so something like *Jump to Definition* with a Rust definition snippet could easily be implemented.

## Planned Features

### Resources

This is my next task, populating the resources tab.

### Editing the Scene and Components

I plan to let you edit all the components.
THe UI and dataflow are ready for it, I just need to add the logic.

You'll also be able to spawn/despawn entities and add/remove components.

This may require crate functionality to expose the default values of a type?

### Watching Components

I plan to make the app watch components and show live changes.
Highlighting changed properties would be a nice-to-have.

### Events/Messages Tab

I want to let you edit and send Events and Messages to your game.
I want you to be able to create templates for commonly sent payloads and even schedule some to run automatically.

This will require crate functionality to expose registered events, messages, their types, triggering them, etc.

### Systems Tab

I want to display the systems currently active in the current state.
I can use the signature of the system to provide quick access to pre-filled query views.

This will require crate functionality to expose app states, schedules and their systems.
