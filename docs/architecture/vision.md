# Balora Mobile Vision

## Overview

**Balora Mobile** is not a standalone pharmacy management application. It is a high-performance mobile companion for **Balora Desktop**, designed to extend the desktop experience into the field while keeping all business logic centralized.

The mobile application acts as a fast, reliable, and intelligent client for scanning, inventory operations, product management, and warehouse workflows.

**Balora Desktop remains the Single Source of Truth.**

---

# Vision

Build the fastest, most reliable, and easiest-to-use mobile companion for pharmacy inventory management.

The application should feel as responsive and dependable as professional warehouse devices while remaining simple enough to be used by any pharmacy employee.

---

# Core Principles

* Mobile is a **Dumb Client**.
* All business rules live inside **Balora Desktop**.
* Zero data loss.
* Offline-first architecture.
* High-performance scanning.
* Enterprise-grade reliability.
* Clean, maintainable architecture.
* Easy future expansion.

---

# Technology Stack

## Core

* Flutter 3.x
* Dart 3.x
* Riverpod 3
* AsyncNotifier
* Freezed
* Drift
* GoRouter
* Dio
* WebSocket

## Architecture

* Clean Architecture
* Feature First
* Repository Pattern
* Result Pattern
* Offline First
* Optimistic UI

---

# Scanner

The scanner is one of the most important parts of the application.

It should provide an experience comparable to professional Zebra-style devices.

## Supported Barcode Types

* QR Code
* EAN-13
* EAN-8
* UPC
* Code128
* Code39
* DataMatrix

## Features

* Continuous Scan
* Single Scan
* Scan Window
* Torch
* Zoom
* Auto Focus
* Duplicate Filter
* Validation
* Scan History
* Beep
* Vibration

---

# Performance Goals

The application must achieve the following:

* Camera startup in less than one second.
* Barcode decoding in under 200ms under good conditions.
* Scan at least 300 consecutive products without freezing.
* No UI blocking while synchronizing.
* Optimized battery usage during long inventory sessions.

---

# Product Management

Users can perform the following actions from the mobile application:

* Add Product
* Edit Product
* Search Products
* View Product Details
* Change Barcode
* Edit Prices (Permission Based)
* Edit Quantity
* View Product Image
* View Current Stock

---

# Inventory Management

The inventory module supports:

* Batch Scan
* Continuous Scan
* Temporary Save
* Resume Later
* Quantity Comparison
* Inventory Differences
* Inventory Approval

---

# Receiving

Support receiving operations including:

* Receiving Items
* Batch Number
* Expiry Date
* Quantity

---

# Synchronization

The application never depends on a permanent internet connection.

Every operation follows this flow:

```text
Scan
    ↓
Queue
    ↓
Sync
    ↓
ACK
```

If connectivity is lost:

* No data is lost.
* Operations are stored locally.
* Synchronization resumes automatically once connectivity returns.

---

# Connectivity

Communication with Balora Desktop uses:

* REST APIs
* WebSockets

Providing:

* Real-time communication
* Notifications
* Device Status
* Fast Updates

---

# Security

The application includes:

* QR Pairing
* Authentication Tokens
* Device Binding
* Remote Logout
* Session Management
* Permission Management

---

# Roles & Permissions

All permissions are managed by **Balora Desktop**.

Example roles include:

## Administrator

* Full Access

## Pharmacist

* Add Products
* Edit Products
* Search
* Inventory

## Warehouse Employee

* Scanner
* Inventory
* Receiving

## Staff

* Scanner Only

---

# Offline Experience

The application continues working even without internet.

Available offline:

* Scanner
* Queue
* Cache
* Session
* Scan History

Once connectivity returns, synchronization happens automatically.

---

# System Design

```text
Balora Desktop
        │
Business Logic
        │
REST / WebSocket
        │
Balora Mobile
        │
├── Scanner
├── Inventory
├── Products
├── Receiving
└── Settings
```

The mobile application never owns business rules.

Its responsibility is to capture user intent, synchronize data, and provide an exceptional user experience.

---

# Future Expansion

The architecture is designed for long-term growth.

Future capabilities include:

* RFID
* NFC
* Zebra Devices
* Honeywell Devices
* Bluetooth Barcode Scanners
* Cloud Synchronization
* Multi-Warehouse Support

All of these can be added without rewriting the application architecture.

---

# Quality Standards

The project follows modern software engineering practices.

Including:

* Unit Tests
* Widget Tests
* Integration Tests
* Strict Lint Rules
* ADR Documentation
* Design System
* Telemetry

---

# Target Market

Balora Mobile is designed for professional use in:

* Pharmacy Point of Sale (POS)
* Warehouse Management Systems (WMS)
* Pharmacy Chains
* Inventory Management

---

# Mission

Deliver a mobile experience that is fast, reliable, secure, and effortless to use, while keeping all business logic centralized inside Balora Desktop.

Balora Mobile is not intended to replace the desktop application—it extends it, enabling pharmacy staff to perform inventory, scanning, receiving, and product management anywhere with confidence and without compromising performance or data integrity.
