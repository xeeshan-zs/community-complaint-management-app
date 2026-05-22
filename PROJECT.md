# PROJECT: Smart Community Complaint Management App

A premium, highly interactive, and responsive Flutter application tailored for a phone screen, with dual support for Windows Desktop (for local preview) and Android APK.

This project is built for **Roll Number 11249** (last digit **9**), featuring **Complaint Filter using Dropdown** as the main interactive feature, plus full CRUD (Add, Read, Update, Delete) capabilities, stats dashboards, and robust edge-case handling.

---

## Tech Stack
- **Framework**: Flutter (SDK >= 3.0)
- **Platforms**: Windows Desktop (for initial development and review), Android Mobile
- **Database**: Firebase Cloud Firestore (`cloud_firestore` & `firebase_core`)
- **State Management**: `provider` (Standard, highly structured, clean, and DRY state management)
- **Local Utilities & Packages**:
  - `uuid` (for client-side ID generation)
  - `intl` (for beautiful date/time formatting)

---

## Architecture & Code Organization (DRY & Modular)

The codebase follows the clean MVC/MVVM-inspired structure:

```
lib/
├── main.dart                      # App entry point, Firebase setup, Provider initialization
├── models/
│   └── complaint.dart             # Typed data model with serialization/deserialization
├── services/
│   └── firebase_service.dart      # Interface with Firebase Firestore (Singleton pattern)
├── providers/
│   └── complaint_provider.dart    # Manages UI state, loading states, filters, and error handling
└── views/
    ├── screens/
    │   ├── splash_screen.dart     # Handles Firebase initialization and initial loading
    │   ├── dashboard_screen.dart  # Responsive layout with stats, list, filter, and registration
    │   └── error_screen.dart      # Robust screen shown if Firebase initialization fails
    └── widgets/
        ├── complaint_card.dart    # Reusable card component for displaying complaints
        ├── complaint_form.dart    # Validation-aware, reusable form component (Add/Edit)
        ├── custom_dropdown.dart   # Reusable styled dropdown widget
        ├── urgency_chips.dart     # Styled choice chips for urgency levels
        ├── stats_card.dart        # Dashboard stats indicators
        └── snackbar_helper.dart   # Centralized helper to show beautiful animated toasts
```

---

## High-Fidelity Responsive Theme (Glassmorphism)
- **Colors**: Harmonic dark mode palette with glowing neon accents:
  - Background: Deep Obsidian Dark (`0xFF121214`)
  - Surface: Glassmorphic Translucent Dark (`0x1FFFFFFF`)
  - Primary: Glowing Indigo-Violet (`0xFF6366F1`)
  - Urgency High: Neon Coral/Red (`0xFFEF4444`)
  - Urgency Medium: Amber/Orange (`0xFFF59E0B`)
  - Urgency Low: Emerald/Green (`0xFF10B981`)
- **Layout**: Adaptive phone screen shell. When run on Desktop, it will display inside a centered, phone-aspect-ratio container with an elegant backdrop, creating a true-to-mobile simulation.
