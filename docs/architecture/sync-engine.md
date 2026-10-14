# Sync Engine

The Sync Engine is a global service (`core/sync/`) responsible for executing the Queue.

## Workflow
1. Items are enqueued with a Priority (High: Inventory, Medium: Updates, Low: Telemetry).
2. The Background Worker triggers synchronization on:
   - App Resume
   - Connectivity Change
   - Manual Sync
   - Scheduled Retry
3. Commands are sent to Balora Desktop.
4. An `ACK` with a matching `CommandId` removes the item from the queue.

## Resiliency
- Drift ensures no pending operations are lost if the app crashes or the OS kills the process.
- Operations maintain a `retryCount` and `status` to prevent infinite loops.
