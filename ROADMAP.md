# ROADMAP: Smart Community Complaint Management App

Structured checklist for the complete development lifecycle.

---

## Phase 1: Environment & Flutter Project Initialization
- [ ] Locate/verify Flutter installation and set up command path.
- [ ] Create a brand new Flutter project: `flutter create --org com.society --platforms=windows,android .`
- [ ] Add all necessary dependencies to `pubspec.yaml` (`provider`, `cloud_firestore`, `firebase_core`, `uuid`, `intl`).
- [ ] Enable Windows Desktop support.

## Phase 2: Data Models & Singleton Services (DRY)
- [ ] Create typed `Complaint` class (`models/complaint.dart`) with `toMap()` and `fromMap()` methods.
- [ ] Set up Firebase Firestore Service (`services/firebase_service.dart`) utilizing the Singleton pattern.
- [ ] Define CRUD operations inside `FirebaseService` (Create, Stream all, Update, Delete).

## Phase 3: State Management & Providers (State & Filtering)
- [ ] Implement `ComplaintProvider` (`providers/complaint_provider.dart`) to manage:
  - List of loaded complaints
  - Current filter values (Type, Urgency, Status)
  - UI Loading/Submitting state
  - Error messages and handling
  - Calculations for top-level Dashboard Stats
- [ ] Connect Provider to the root of the app in `main.dart`.

## Phase 4: Core Screens & Phone-Aesthetic Layout
- [ ] Implement the mobile-aspect shell for Windows Desktop preview (centered phone container).
- [ ] Design the Glassmorphic Dark Obsidian theme (`ThemeData` setup in `main.dart`).
- [ ] Create `SplashScreen` (`screens/splash_screen.dart`) to handle Firebase initialization stream.
- [ ] Create `ErrorScreen` (`screens/error_screen.dart`) for fallback if Firebase core fails.

## Phase 5: Registration Form & ChoiceChips Widget
- [ ] Design the Form Sheet (`widgets/complaint_form.dart`) with clean `TextFormField` fields.
- [ ] Add Form Validations (non-empty fields, name checks, min lengths).
- [ ] Build custom Choice Chips for Urgency levels with tailored neon borders/glows.
- [ ] Create expected resolution slider (discrete 1-14 values).
- [ ] Implement Submission Loading overlay blocking concurrent submissions.

## Phase 6: Real-time List Screen & Stats cards
- [ ] Code the Main Dashboard Screen (`screens/dashboard_screen.dart`).
- [ ] Develop the Stats Dashboard Header (Total, High, Resolved, Avg Days cards).
- [ ] Build `ComplaintCard` showing all detailed metadata, date formatted via `intl`.
- [ ] Implement beautiful Empty State screen if complaint stream is empty.

## Phase 7: Interactive Filtering Dropdown (Roll 459 Feature)
- [ ] Build Filtering row with three distinct custom Styled Dropdowns:
  - Filter by Type
  - Filter by Urgency
  - Filter by Status
- [ ] Connect Dropdowns to `ComplaintProvider` to update visual lists and Stats instantly.
- [ ] Implement the dynamic `"Clear Filters"` button.

## Phase 8: CRUD Operations (Edit & Delete Bonus)
- [ ] Add Swipe-To-Delete functionality using standard Flutter `Dismissible` widget.
- [ ] Design custom dialog confirmations for deletions.
- [ ] Code the Edit Modal sheet (reusing the registration form widget to keep code strictly DRY!).
- [ ] Create a helper utility for custom Snackbars/Toasts.

## Phase 9: Verification, Reflection & Submission
- [ ] Compile and verify Windows Desktop App works with zero bugs and smooth animations.
- [ ] Verify error states (simulate offline/no network) and perfect flows.
- [ ] Write `reflection.md` answering the three exam questions.
- [ ] Compile final APK (`flutter build apk --split-per-abi` or `flutter build apk`).
