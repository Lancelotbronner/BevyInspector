# Bevy Inspector

> # Note
> Very WIP

## Overview

An app which uses the [Bevy Remote Protocol](https://docs.rs/bevy_remote/latest/bevy_remote/index.html) to help you debug and develop your games.

Currently only macOS is intented for support but I want to extend this to iPad and iPhone too.

## Features

### Project Oriented

This is a document app so you can keep your configuration on a per-workspace level.

### Schema Tab

There's a schema tab that lets you look at all the types registered by `bevy`.

This is currently useful to find the full name of a type (such as `bevy_ecs::name::Name`) to use in the Query Tab.

The schema is saved to the project.

### World Tab

Write queries and view the resulting hierarchy in a table.
Select an entity to reveal a component inspector.
Save your queries to the project, allowing quick access to what you care about.

Currently the query format is either `*` or a comma-separated list of full component name.
