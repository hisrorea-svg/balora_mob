# API Protocol

## REST Endpoints
TBD based on balora_custom specifications. General structure will follow `/api/v1/`.

## WebSocket Messages
WebSockets are used for real-time connectivity, live notifications, and device health status.

### Pairing Payload (QR)
Parsed by the scanner to connect to the desktop server.
```json
{
  "server": "https://192.168.1.15:8080",
  "pairToken": "xxxxx",
  "deviceName": "Balora POS",
  "expiresAt": "2026-07-05T10:00:00Z",
  "version": 1
}
```

### Scan Command (Queue Item)
Sent from mobile to desktop.
```json
{
  "commandId": "uuid-v4",
  "type": "scan",
  "barcode": "8901234567890",
  "timestamp": "2026-07-04T10:00:00Z",
  "deviceId": "uuid"
}
```

### ACK
Received from desktop to mobile to acknowledge completion of a command.
```json
{
  "commandId": "uuid-v4",
  "status": "success"
}
```
