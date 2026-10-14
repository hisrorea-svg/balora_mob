# 1. Use Riverpod for State Management

Date: 2026-07-04

## Status
Accepted

## Context
We need a robust, scalable state management solution that supports dependency injection, caching, and clean separation of concerns.

## Decision
We will use `riverpod` (specifically `riverpod_annotation` for code generation) alongside `AsyncNotifier` to manage application state.

## Consequences
- Allows explicit decoupled testing of the `application` layer (Controllers) without mounting the UI.
- Will require the use of `build_runner` for code generation.
