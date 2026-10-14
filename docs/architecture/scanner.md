# Scanner Pipeline

The scanner pipeline is designed to handle extremely fast continuous scanning without blocking the UI or losing data.

```text
Camera
  ↓
ML Kit (Speed & Accuracy)
  ↓
Parser (EAN, QR, Code128)
  ↓
Validation (Format Check, Checksum)
  ↓
Duplicate Filter (Barcode + Timestamp)
  ↓
Global Queue (Priority Based)
  ↓
Optimistic UI (Visual Success)
  ↓
Sync Service (Background)
  ↓
Balora Desktop Server (Executes Business Rules)
  ↓
ACK (Acknowledged via CommandId)
  ↓
Completed
```

## Details
- **Duplicate Filter**: Compares the barcode and the timestamp of the last scan to prevent registering the same item 10 times in a single second.
- **Queue**: Pushes the scan intent to the Drift database.
- **Optimistic UI**: Immediately reflects success locally.
