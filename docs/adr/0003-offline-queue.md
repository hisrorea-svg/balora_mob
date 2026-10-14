# 3. Offline Queue and Optimistic UI

Date: 2026-07-04

## Status
Accepted

## Context
High-speed inventory scanning in retail/warehouse environments cannot be slowed down by Wi-Fi latency. The UI must remain fully responsive and visually indicate success instantly, while the actual synchronization happens in the background.

## Decision
We will implement an Optimistic UI backed by a Global Prioritized Queue.

## Consequences
- The Mobile App operates as a "Dumb Client", solely acting as an intent delivery mechanism.
- All operations (Add, Scan, Delete) are pushed to the Queue via Idempotent CQRS Commands.
- If the sync fails after all retries, or if `Balora Desktop` rejects the command based on business logic, the Optimistic UI state will be reverted locally and the user notified.
