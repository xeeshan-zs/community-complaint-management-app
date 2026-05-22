# 📱 Community Complaint Management App

> **BSIT-6 Final Lab Exam** | Mobile Application Development  
> **Student**: Kafeel Khan | **Roll No**: 11249  
> **Interactive Feature**: Real-time Dropdown Filtering with Dynamic Statistics

A premium Flutter application for managing community complaints with a sleek **Obsidian Space** dark theme, glassmorphic UI, and Firebase Cloud Firestore backend.

---

## 🚀 Quick Start (Windows)

Just double-click **`run_app.bat`** — it will launch the app instantly!

Or run manually via PowerShell:
```powershell
& "C:\Users\Shani\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe" flutter run -d windows
```

---

## ✨ Features

- 📝 **Register complaints** with type, urgency, and expected resolution days
- 🔍 **Dropdown filtering** by Type / Urgency / Status (Roll 11249 exam feature)
- 📊 **Live statistics** — Total, High Urgency, Resolved, Avg Days (updates with filters)
- ✏️ **Edit & Delete** complaints (DRY form widget reused for both)
- ☁️ **Firebase Firestore** real-time cloud sync (toggleable from settings)
- 📴 **Offline Sandbox Mode** — works 100% without network
- 📱 **Phone-in-desktop shell** — mobile UI centered beautifully on Windows

---

## 📂 Project Structure

```
lib/
├── main.dart                   # Entry point & theme
├── models/complaint.dart       # Complaint data model
├── services/firebase_service.dart  # Firestore CRUD singleton
├── providers/complaint_provider.dart  # State + filters + stats
└── views/
    ├── screens/dashboard_screen.dart  # Main screen
    └── widgets/complaint_form.dart    # Reusable Add/Edit form
```

---

## 📖 Documentation

| File | Purpose |
|------|---------|
| [`EXPLANATION.md`](EXPLANATION.md) | Full technical explanation of architecture, features, and design |
| [`reflection.md`](reflection.md) | Exam reflection answers |
| [`PROJECT.md`](PROJECT.md) | Project spec and tech stack |
| [`REQUIREMENTS.md`](REQUIREMENTS.md) | Functional requirements |
| [`ROADMAP.md`](ROADMAP.md) | Development roadmap |

---

## 🎨 Design

**Obsidian Space Theme** — deep dark backgrounds, glassmorphic cards, neon violet accents.  
Runs in a **centered phone-bezel shell** on Windows Desktop for an authentic mobile preview.

---

*Flutter 3.44.0 · Firebase Cloud Firestore · Provider State Management*
