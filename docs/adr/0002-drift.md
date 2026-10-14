# 2. Use Drift for Local Database

Date: 2026-07-04

## Status
Accepted

## Context
The application relies heavily on an Offline-First Sync Queue. We need a performant local SQLite database that provides type-safe Dart APIs and supports reactive streams.

## Decision
We will use `drift` as the local database.

## Consequences
- The database schema will be kept lightweight (Queue, Sessions, Cache, Scan History).
- `drift` will manage the persistence of the Sync Queue, guaranteeing zero data loss during connectivity drops or app crashes.
