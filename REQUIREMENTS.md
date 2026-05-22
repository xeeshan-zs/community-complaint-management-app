# REQUIREMENTS: Smart Community Complaint Management App

This document outlines the detailed specifications, functional requirements, and visual/logical edge cases for the app.

---

## 1. Complaint Registration Form
Users must be able to register community complaints with strict inputs and field validation.

### Inputs
- **Resident Name**: TextField. Cannot be empty. Trim whitespace.
- **Complaint Title**: TextField. Minimum 5 characters, cannot be empty.
- **Description**: TextField (Multi-line, min 3 lines). Cannot be empty.
- **Complaint Type**: Styled Custom Dropdown. Choices:
  - `Water Leakage`
  - `Electricity Failure`
  - `Garbage Collection`
  - `Security Issue`
  - `Street Light Damage`
- **Urgency Level**: Reusable custom Choice Chips. Choices:
  - `Low` (Emerald Green accent)
  - `Medium` (Amber Orange accent)
  - `High` (Neon Coral Red accent)
- **Expected Resolution Days**: Elegant Slider from `1` to `14` days, showing discrete values with a numeric label.

### Edge Cases & Error States (Form)
- **Validation Failure**: If any field is empty, trigger standard Flutter inline validation (`validator` parameter of `TextFormField`) showing customized red error text under each input. Scroll to the first error if applicable.
- **Submission Lock**: The submit button must disable and show a CircularProgressIndicator during the write operation. Any double-tap or concurrent submission attempt is blocked.
- **Database Write Error**: If Firestore write fails (e.g., timeout, lack of internet, auth permission error), catch the exception, stop loading state, keep the form data intact, and display a prominent warning Snackbar with a "Try Again" action button.
- **Database Write Success**: Auto-close the registration sheet/modal, clear all input controllers, and show a beautiful glowing success Snackbar.

---

## 2. Real-Time Complaint List & Dashboard
Displays complaints in a scrollable, modern dashboard interface.

### Features
- **Real-Time Synchronization**: Live sync with Firebase Firestore `snapshots()`. Any changes on the server or other devices reflect instantly.
- **Visual Presentation**:
  - Each card must display: Title, Resident Name, Type, Urgency level (color-coded tag), Expected Resolution Days, and Status (Pending vs. Resolved).
  - Date & Time must be formatted as: `MMM dd, yyyy - hh:mm a` (e.g. `May 22, 2026 - 03:15 PM`).
- **Stats Dashboard (DRY & Premium)**:
  - Displays: Total Complaints, High Urgency Count, Resolved Count, and Avg. Expected Resolution Days. These values must update dynamically when filters are applied!

### Edge Cases & Error States (List)
- **Zero Complaints (Empty State)**: If Firestore contains no documents, display a beautiful, custom vector/icon empty state with text: `"Your community is pristine! No complaints found."` and a `"File a Complaint"` button.
- **Loading State**: While waiting for the stream to initialize, show a sleek shimmer effect or a premium centered custom loader.
- **Filtering Yields No Results**: If filters are active but no complaints match, display: `"No complaints found for the selected filters."` with a custom `"Clear Filters"` button.
- **Network Disconnection**: If Firestore stream encounters a network interruption, display a subtle but clear offline bar at the top/bottom: `"Connection lost. Running in offline/cached mode."`

---

## 3. Interactive Filtering (Roll Number 459 - Ends in 9)
Tailored interactive filtering panel at the top of the list.

### Features
- **Type Filter Dropdown**: Choose to view `All` or specific types (`Water Leakage`, etc.).
- **Urgency Filter Dropdown**: Choose to view `All`, `High`, `Medium`, or `Low`.
- **Status Filter Dropdown**: Choose to view `All`, `Pending`, or `Resolved`.
- **Reset Capability**: An elegant `"Clear Filters"` action button when any filter is active.

---

## 4. Bonus Features & Operations (Add, Update, Delete, Edit)
- **Swipe-to-Delete**: Swiping a card left/right triggers a full-width red background with a Trash icon. Shows a styled Confirmation Dialog: `"Delete Complaint?"` with `"Cancel"` and `"Delete"` actions.
- **Status Toggle**: Residents or Admins can mark a complaint as `Resolved` or `Pending` with a quick toggle or button click on the card.
- **Full Complaint Editor**: Clicking a card opens a modal sheet populated with the current complaint's details, letting the user update title, description, urgency, and resolution days, which then synchronizes back to Firebase in real-time.
