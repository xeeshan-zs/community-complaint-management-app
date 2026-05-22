# 📱 Community Complaint Management App — Full Project Explanation

> **Course**: Mobile Application Development  
> **Exam**: BSIT-6 Final Lab Exam  
> **Student**: Kafeel Khan | **Roll No**: 11249  
> **Interactive Feature (Roll No. ending in 9)**: Real-time Dropdown Filtering with Dynamic Statistics  
> **Firebase Project**: `community-complaint-management`

---

## 📋 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Design Pattern](#2-architecture--design-pattern)
3. [Folder Structure](#3-folder-structure)
4. [Core Features](#4-core-features)
5. [Roll No. 459 — Specific Feature: Dropdown Filtering](#5-roll-no-459--specific-feature-dropdown-filtering)
6. [Firebase Integration](#6-firebase-integration)
7. [UI/UX Design Philosophy](#7-uiux-design-philosophy)
8. [Key Widgets Explained](#8-key-widgets-explained)
9. [State Management with Provider](#9-state-management-with-provider)
10. [Offline Sandbox Mode](#10-offline-sandbox-mode)
11. [DRY Principle Applied](#11-dry-principle-applied)
12. [How to Run](#12-how-to-run)
13. [Reflection Summary](#13-reflection-summary)

---

## 1. Project Overview

The **Community Complaint Management App** is a full-stack Flutter mobile application that allows residents of a community to:

- **Register complaints** about community issues (Road, Water, Electricity, Sanitation, etc.)
- **Track complaint status** in real-time (Pending, In Progress, Resolved)
- **Assign urgency levels** (Low, Medium, High, Critical)
- **Filter and analyze** complaints using interactive dropdowns
- **View live statistics** — total complaints, high urgency count, resolved count, and average expected resolution days

The app runs natively on **Windows Desktop** (for local development/preview) and is designed to compile to **Android APK** for mobile deployment.

---

## 2. Architecture & Design Pattern

The app follows a clean, layered architecture using **Provider** for state management:

```
┌─────────────────────────────────────────────────────────┐
│                      UI LAYER                           │
│   Screens (Dashboard, Splash)  +  Widgets (Forms, Cards)│
└──────────────────────┬──────────────────────────────────┘
                       │  listens / rebuilds via Consumer
┌──────────────────────▼──────────────────────────────────┐
│                   STATE LAYER                           │
│              ComplaintProvider (ChangeNotifier)         │
│   - filteredComplaints   - stats aggregation            │
│   - activeFilters        - loading states               │
└──────────────────────┬──────────────────────────────────┘
                       │  calls CRUD methods
┌──────────────────────▼──────────────────────────────────┐
│                  SERVICE LAYER                          │
│           FirebaseService (Singleton)                   │
│   - Firestore streams   - add/update/delete ops         │
└──────────────────────┬──────────────────────────────────┘
                       │  reads/writes
┌──────────────────────▼──────────────────────────────────┐
│                   DATA LAYER                            │
│    Firebase Cloud Firestore  ←→  Local In-Memory Cache  │
└─────────────────────────────────────────────────────────┘
```

### Design Principles Applied:
| Principle | How Applied |
|-----------|-------------|
| **DRY** (Don't Repeat Yourself) | Single `ComplaintForm` widget used for both Add and Edit |
| **Singleton Pattern** | `FirebaseService` is a singleton — one instance app-wide |
| **Observer Pattern** | `ChangeNotifier` + `Consumer` for reactive UI updates |
| **Separation of Concerns** | Models, Services, Providers, Views are clearly separated |
| **Graceful Degradation** | App boots offline, opts into cloud sync when available |

---

## 3. Folder Structure

```
lib/
├── main.dart                          # App entry point, theme, providers
├── firebase_options.dart              # Auto-generated Firebase config
│
├── models/
│   └── complaint.dart                 # Complaint data class (fromMap/toMap)
│
├── services/
│   └── firebase_service.dart          # Firestore CRUD singleton service
│
├── providers/
│   └── complaint_provider.dart        # Central state + filter + stats logic
│
└── views/
    ├── screens/
    │   ├── splash_screen.dart          # Animated loading/boot screen
    │   └── dashboard_screen.dart       # Main app screen with all features
    └── widgets/
        └── complaint_form.dart         # Reusable form (Add + Edit, DRY)
```

---

## 4. Core Features

### ✅ Complaint Registration
- A bottom sheet form slides up with smooth animation
- Fields: Title, Description, Type (dropdown), Urgency (choice chips), Expected Resolution Days (slider)
- Full validation — no empty fields, minimum character requirements
- Loading overlay with animated spinner while submitting

### ✅ Real-time Complaint List
- Each complaint is displayed as a **glassmorphic card**
- Cards are collapsible — tap to expand full details
- Color-coded urgency badges (🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low)
- Status chips update visually: Pending → In Progress → Resolved

### ✅ CRUD Operations
- **Create**: Add new complaint via FAB (Floating Action Button)
- **Read**: Real-time stream from Firestore OR in-memory local list
- **Update**: Edit any complaint via swipe or long-press → DRY form reuse
- **Delete**: Swipe-to-delete with confirmation dialog to prevent accidents

### ✅ Dashboard Statistics
Four live stat cards at the top of the dashboard:
| Stat | Description |
|------|-------------|
| 📊 Total | Total count of all complaints (or filtered subset) |
| 🔴 High Urgency | Count of High + Critical complaints |
| ✅ Resolved | Count of complaints with Resolved status |
| ⏱ Avg Days | Average expected resolution days across all complaints |

---

## 5. Roll No. 459 — Specific Feature: Dropdown Filtering

> **Exam Requirement**: Roll numbers ending in **9** must implement **Dropdown-based real-time filtering**.

### Implementation

Three dropdown menus in the filter panel dynamically control the complaint list:

```dart
// In ComplaintProvider
String? _filterType;     // "Road", "Water", "Electricity", etc. (or null = All)
String? _filterUrgency;  // "Low", "Medium", "High", "Critical" (or null = All)
String? _filterStatus;   // "Pending", "In Progress", "Resolved" (or null = All)
```

### How Filtering Works

```
User selects "High" in Urgency dropdown
        ↓
ComplaintProvider.setFilterUrgency("High") called
        ↓
notifyListeners() triggers UI rebuild
        ↓
filteredComplaints getter applies all active filters:
  - type filter    (if set)
  - urgency filter (now set to "High")
  - status filter  (if set)
        ↓
Dashboard list rebuilds showing only High urgency items
        ↓
Stats cards ALSO recalculate based on filtered subset:
  - Total    = 12 (filtered)
  - Resolved = 4  (from filtered 12)
  - Avg Days = 5.2 days average
```

### The Stats Are Always in Sync with the Filter

This is the **key exam feature** — all four statistics recalculate **on-the-fly** whenever any dropdown changes, because they all read from `filteredComplaints` (not the raw master list):

```dart
int get totalCount => filteredComplaints.length;
int get highUrgencyCount => filteredComplaints.where(
    (c) => c.urgency == 'High' || c.urgency == 'Critical').length;
int get resolvedCount => filteredComplaints.where(
    (c) => c.status == 'Resolved').length;
double get avgResolutionDays => filteredComplaints.isEmpty ? 0 :
    filteredComplaints.map((c) => c.expectedDays).reduce((a,b)=>a+b) / filteredComplaints.length;
```

---

## 6. Firebase Integration

### Firebase Project Details
| Field | Value |
|-------|-------|
| Project Name | Community Complaint Management |
| Project ID | `community-complaint-management` |
| Project Number | 495288152724 |
| Platform | Android + Windows |
| Student | Kafeel Khan (Roll No: 11249) |

### Collection Structure (Firestore)

```
complaints/                    ← Firestore Collection
  └── {auto-document-id}/      ← Each complaint document
        ├── id: string
        ├── title: string
        ├── description: string
        ├── type: string          ("Road" | "Water" | "Electricity" | ...)
        ├── urgency: string       ("Low" | "Medium" | "High" | "Critical")
        ├── status: string        ("Pending" | "In Progress" | "Resolved")
        ├── expectedDays: int     (1–14)
        └── createdAt: timestamp
```

### Offline-First Strategy

The app is designed with an **offline-first** architecture:
- On startup, Firebase is **not initialized** (prevents crash on machines without Android/network)
- Data is stored in-memory in `ComplaintProvider._localComplaints`
- User can toggle **Cloud Sync** from the settings panel → triggers `initializeFirebaseDynamic()`
- If Firestore connection fails, app gracefully reverts to offline mode

---

## 7. UI/UX Design Philosophy

### Obsidian Space Theme

The entire app uses a custom dark theme with glassmorphic elements:

| Element | Color / Style |
|---------|--------------|
| Background | Deep obsidian `#0A0A0F` gradient |
| Glass cards | `rgba(255,255,255,0.07)` with blur backdrop |
| Primary accent | Neon violet `#7C3AED` |
| Secondary accent | Electric cyan `#06B6D4` |
| Success | Emerald `#10B981` |
| Danger / Critical | Rose `#F43F5E` |
| Font | System default (clean, readable) |

### Phone-in-Desktop Shell

On Windows Desktop, the app renders inside a **simulated phone bezel**:
- Fixed width: 410px, height: 820px
- Rounded corners (40px radius)
- Glowing obsidian shadow border
- Centered on the desktop canvas
- Automatically switches to fullscreen on real mobile devices

---

## 8. Key Widgets Explained

### `ComplaintCard`
A collapsible card widget that displays a complaint summary. Tap to reveal full details. Features:
- Animated expand/collapse using `AnimatedContainer`
- Color-coded urgency badge
- Status action buttons (Pending → In Progress → Resolved progression)
- Edit and Delete context actions

### `ComplaintForm` (DRY Reuse)
One form widget used in **two contexts**:
1. **Add Mode** — launched from FAB, starts with empty fields
2. **Edit Mode** — launched from edit action, pre-filled with existing complaint data

```dart
ComplaintForm(
  existingComplaint: complaint,  // null = Add mode, Complaint = Edit mode
  onSubmit: (data) => provider.addOrUpdateComplaint(data),
)
```

### `FilterDropdowns`
Three `DropdownButtonFormField` widgets wrapped in a styled row. Each dropdown:
- Has an "All" option (null value) to clear filter
- Animates a filter chip when active
- Shows a "Filters Active" badge on the app bar

### `StatCard`
Animated counter card displaying a statistic:
- Icon + label + animated numeric value
- Reactive: rebuilds whenever `ComplaintProvider` notifies

---

## 9. State Management with Provider

`ComplaintProvider` extends `ChangeNotifier` and is the single source of truth:

```dart
class ComplaintProvider extends ChangeNotifier {
  // Core data
  List<Complaint> _localComplaints = [];        // offline cache
  List<Complaint> _firebaseComplaints = [];     // cloud data (when synced)
  StreamSubscription? _subscription;           // Firestore stream handle

  // Filter state
  String? _filterType;
  String? _filterUrgency;
  String? _filterStatus;

  // Computed properties (reactive)
  List<Complaint> get filteredComplaints { ... }   // filtered view
  int get totalCount { ... }                        // stat from filtered
  int get highUrgencyCount { ... }                  // stat from filtered
  int get resolvedCount { ... }                     // stat from filtered
  double get avgResolutionDays { ... }              // stat from filtered
}
```

---

## 10. Offline Sandbox Mode

The app boots in **Sandbox Mode** by default — this means:
- ✅ No Firebase initialization on startup
- ✅ Zero chance of crash due to missing Android SDK or Firestore config
- ✅ All features work with local in-memory data
- ✅ Pre-seeded with sample complaints for immediate demonstration

To enable Cloud Sync:
1. Tap the ⚙️ settings icon (top right of dashboard)
2. Toggle "Enable Cloud Sync"
3. App initializes Firebase dynamically and connects to Firestore

---

## 11. DRY Principle Applied

| Area | DRY Implementation |
|------|--------------------|
| **Form UI** | `ComplaintForm` widget handles Add + Edit (one widget, two modes) |
| **Firestore Access** | `FirebaseService` singleton — single instance for all DB calls |
| **Filter Logic** | All filter operations in `filteredComplaints` getter — no duplication |
| **Stats** | All stats computed from `filteredComplaints` — one source, four outputs |
| **Error Handling** | Single `_handleError()` method in provider used by all async ops |

---

## 12. How to Run

### Prerequisites
- Windows 10/11 with Visual Studio C++ Build Tools
- Puro Flutter SDK Manager (manages Flutter 3.44.0 stable)

### Run the App
Double-click `run_app.bat` — it will automatically launch the Flutter Windows app using Puro.

Or manually:
```powershell
# Using Puro
& "C:\Users\Shani\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe" flutter run -d windows
```

---

## 13. Reflection Summary

### Q1: Which widget or feature was new to you?
The **phone-in-desktop shell** using `LayoutBuilder` and adaptive constraints was the most innovative technique — presenting a mobile layout perfectly centered inside a desktop window with rounded corners, glowing borders, and correct aspect ratio.

### Q2: Was SharedPreferences suitable?
**No.** SharedPreferences stores only key-value primitives and has no querying capability. This app needs:
- Complex structured data (nested complaint objects)
- Real-time multi-user cloud sync
- Advanced filtering and aggregation  
→ Firebase Cloud Firestore is the correct solution.

### Q3: Which part required the most debugging?
The **Firestore StreamSubscription lifecycle** inside `ComplaintProvider`. Initially, hot-reloads and filter changes caused duplicate stream subscriptions and memory leaks. Solution: strict subscription management with `_subscription?.cancel()` before re-subscribing, and computing all stats from a single `filteredComplaints` getter.

---

*Submitted for BSIT-6 Final Lab Exam — Mobile Application Development*  
*Student: Kafeel Khan | Roll Number: 11249 | Feature: Dropdown Real-time Filtering with Live Statistics*
