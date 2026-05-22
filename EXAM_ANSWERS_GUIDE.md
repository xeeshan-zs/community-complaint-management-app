# 📸 Exam Answer Screenshot Guide
## Community Complaint Management App
**Student**: Kafeel Khan | **Roll No**: 11249  
**GitHub**: https://github.com/xeeshan-zs/community-complaint-management-app

> This file tells you **exactly** which file to open, which lines to show, and what each screenshot answers in the exam docx.

---

## 📋 How to Take Screenshots for the Docx

1. Open the file listed in each section in **VS Code** or any code editor
2. Press `Ctrl+G` → type the line number to jump directly to it
3. Select/highlight the lines shown in each section
4. Press `Alt+PrintScreen` → paste into Word docx

---

---

# Q1 — Complaint Registration Form (Data Entry with Validation)

## Screenshot 1A: The Complaint Data Model
**File**: `lib/models/complaint.dart`  
**Lines**: 1 – 40  
**What it shows**: The `Complaint` class with all fields (title, type, urgency, resolutionDays, status, createdAt) and `toMap()` for Firestore storage.

```dart
// lib/models/complaint.dart  Lines 3–24
class Complaint {
  final String id;
  final String title;
  final String description;
  final String residentName;
  final String type;
  final String urgency;
  final int resolutionDays;
  final String status;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.residentName,
    required this.type,
    required this.urgency,
    required this.resolutionDays,
    required this.status,
    required this.createdAt,
  });
```

---

## Screenshot 1B: Form Validation Logic
**File**: `lib/views/widgets/complaint_form.dart`  
**Lines**: 163 – 206  
**What it shows**: `TextFormField` validators — name cannot be empty, title needs min 5 chars, description cannot be empty.

```dart
// lib/views/widgets/complaint_form.dart  Lines 168–205
validator: (val) {
  if (val == null || val.trim().isEmpty) {
    return 'Please enter your name';
  }
  return null;
},
// ...title validator...
validator: (val) {
  if (val == null || val.trim().isEmpty) {
    return 'Please enter a title';
  }
  if (val.trim().length < 5) {
    return 'Title must be at least 5 characters long';
  }
  return null;
},
```

---

## Screenshot 1C: Submit Button with Loading Lock
**File**: `lib/views/widgets/complaint_form.dart`  
**Lines**: 293 – 330  
**What it shows**: The submit `ElevatedButton` — disables when `isSubmitting` is true and shows `CircularProgressIndicator` instead (prevents double-tap).

```dart
// lib/views/widgets/complaint_form.dart  Lines 298–327
onPressed: provider.isSubmitting ? null : _submitForm,
// ...
child: provider.isSubmitting
    ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
    : Text(isEditing ? 'Save Changes' : 'Submit Complaint'),
```

---

## Screenshot 1D: Complaint Type Dropdown & Urgency Chips in Form
**File**: `lib/views/widgets/complaint_form.dart`  
**Lines**: 35 – 57  
**What it shows**: List of complaint types + DRY initialization for add vs edit mode.

```dart
// lib/views/widgets/complaint_form.dart  Lines 35–57
final List<String> _complaintTypes = [
  'Water Leakage',
  'Electricity Failure',
  'Garbage Collection',
  'Security Issue',
  'Street Light Damage'
];
// DRY init: populate if edit, use defaults if new
_nameController = TextEditingController(text: c?.residentName ?? '');
_selectedType = c != null && _complaintTypes.contains(c.type)
    ? c.type : _complaintTypes.first;
_selectedUrgency = c?.urgency ?? 'Low';
_resolutionDays = (c?.resolutionDays ?? 3).toDouble();
```

---

## Screenshot 1E: Resolution Days Slider
**File**: `lib/views/widgets/complaint_form.dart`  
**Lines**: 246 – 290  
**What it shows**: `Slider` widget from 1 to 14 days with live value label.

```dart
// lib/views/widgets/complaint_form.dart  Lines 279–290
child: Slider(
  value: _resolutionDays,
  min: 1,
  max: 14,
  divisions: 13,
  onChanged: (val) {
    setState(() { _resolutionDays = val; });
  },
),
```

---

---

# Q2 — Real-Time List & Dashboard Statistics

## Screenshot 2A: Firebase Firestore Real-Time Stream
**File**: `lib/services/firebase_service.dart`  
**Lines**: 76 – 85  
**What it shows**: The `snapshots()` Firestore stream that syncs complaints in real-time.

```dart
// lib/services/firebase_service.dart  Lines 76–85
return FirebaseFirestore.instance
    .collection('complaints')
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) {
  return snapshot.docs.map((doc) {
    return Complaint.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }).toList();
});
```

---

## Screenshot 2B: Stats Dashboard — All Four Counters
**File**: `lib/views/screens/dashboard_screen.dart`  
**Lines**: 617 – 659  
**What it shows**: `StatsGrid` widget — Total Cases, Critical Highs, Resolved Cases, Avg Duration — all reading from `provider`.

```dart
// lib/views/screens/dashboard_screen.dart  Lines 632–658
StatsCard(title: 'TOTAL CASES',   value: provider.totalComplaintsCount.toString(), ...),
StatsCard(title: 'CRITICAL HIGHS', value: provider.highUrgencyCount.toString(), ...),
StatsCard(title: 'RESOLVED CASES', value: provider.resolvedCount.toString(), ...),
StatsCard(title: 'AVG DURATION',
  value: '${avgDays.toStringAsFixed(1)} Days', ...),
```

---

## Screenshot 2C: Stats Computed From Filtered List (DRY, Dynamic)
**File**: `lib/providers/complaint_provider.dart`  
**Lines**: 132 – 145  
**What it shows**: All 4 stats are computed from `filteredComplaints` — so they automatically update whenever a dropdown filter changes.

```dart
// lib/providers/complaint_provider.dart  Lines 133–145
int get totalComplaintsCount => filteredComplaints.length;

int get highUrgencyCount =>
    filteredComplaints.where((c) => c.urgency == 'High').length;

int get resolvedCount =>
    filteredComplaints.where((c) => c.status == 'Resolved').length;

double get avgExpectedResolutionDays {
  if (filteredComplaints.isEmpty) return 0.0;
  int totalDays = filteredComplaints.fold(0, (sum, c) => sum + c.resolutionDays);
  return totalDays / filteredComplaints.length;
}
```

---

## Screenshot 2D: Empty State Edge Case
**File**: `lib/views/screens/dashboard_screen.dart`  
**Lines**: 228 – 284  
**What it shows**: When `allComplaints.isEmpty` — shows a custom empty state with a "Submit First Complaint" button.

```dart
// lib/views/screens/dashboard_screen.dart  Lines 228–284
if (provider.allComplaints.isEmpty) {
  return Center(
    child: Column(children: [
      Icon(Icons.spa_rounded, size: 48, color: Colors.white12),
      Text('No complaints have been reported yet.'),
      ElevatedButton.icon(
        onPressed: () => _openAddSheet(context),
        label: Text('SUBMIT FIRST COMPLAINT'),
      ),
    ]),
  );
}
```

---

## Screenshot 2E: Loading State Edge Case
**File**: `lib/views/screens/dashboard_screen.dart`  
**Lines**: 219 – 226  
**What it shows**: While Firestore stream is loading, a centered `CircularProgressIndicator` is shown.

```dart
// lib/views/screens/dashboard_screen.dart  Lines 220–226
if (provider.isLoading) {
  return const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
    ),
  );
}
```

---

---

# Q3 — Interactive Filtering with Dropdown (Roll No. 11249 — Ends in 9)

## Screenshot 3A: Three Filter Dropdowns UI
**File**: `lib/views/screens/dashboard_screen.dart`  
**Lines**: 662 – 795  
**What it shows**: The entire `DropdownFilterRow` — Type, Urgency, and Status dropdowns built with `DropdownButton`.

```dart
// lib/views/screens/dashboard_screen.dart  Lines 670–715
final List<String> types = [
  'All', 'Water Leakage', 'Electricity Failure',
  'Garbage Collection', 'Security Issue', 'Street Light Damage'
];
final List<String> urgencies = ['All', 'Low', 'Medium', 'High'];
final List<String> statuses  = ['All', 'Pending', 'Resolved'];

// Type dropdown
DropdownButton<String>(
  value: provider.selectedType,
  items: types.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
  onChanged: (val) { if (val != null) provider.setFilterType(val); },
),
```

---

## Screenshot 3B: Filter State in Provider
**File**: `lib/providers/complaint_provider.dart`  
**Lines**: 12 – 16 AND 98 – 120  
**What it shows**: The three filter state variables and the setters that call `notifyListeners()` to trigger UI rebuild.

```dart
// lib/providers/complaint_provider.dart  Lines 12–16
String _selectedType    = 'All';
String _selectedUrgency = 'All';
String _selectedStatus  = 'All';

// Lines 98–120
void setFilterType(String value) {
  _selectedType = value;
  notifyListeners();  // ← triggers UI & stats rebuild
}
void setFilterUrgency(String value) {
  _selectedUrgency = value;
  notifyListeners();
}
void setFilterStatus(String value) {
  _selectedStatus = value;
  notifyListeners();
}
void clearFilters() {
  _selectedType = _selectedUrgency = _selectedStatus = 'All';
  notifyListeners();
}
```

---

## Screenshot 3C: The filteredComplaints Getter (Core Logic)
**File**: `lib/providers/complaint_provider.dart`  
**Lines**: 122 – 130  
**What it shows**: How all three active filters are applied together in one getter — this is what the list AND the stats both read from.

```dart
// lib/providers/complaint_provider.dart  Lines 123–130
List<Complaint> get filteredComplaints {
  return _allComplaints.where((complaint) {
    final matchesType    = _selectedType    == 'All' || complaint.type    == _selectedType;
    final matchesUrgency = _selectedUrgency == 'All' || complaint.urgency == _selectedUrgency;
    final matchesStatus  = _selectedStatus  == 'All' || complaint.status  == _selectedStatus;
    return matchesType && matchesUrgency && matchesStatus;
  }).toList();
}
```

---

## Screenshot 3D: "No Matches" Filter Edge Case
**File**: `lib/views/screens/dashboard_screen.dart`  
**Lines**: 287 – 332  
**What it shows**: When filters are active but no complaints match — shows "No matches found" with a "RESET FILTERS" button.

```dart
// lib/views/screens/dashboard_screen.dart  Lines 287–332
if (provider.filteredComplaints.isEmpty) {
  return Center(
    child: Column(children: [
      Icon(Icons.filter_list_off_rounded, ...),
      Text('No matches found'),
      Text('Try clearing filters to review full records.'),
      TextButton(
        onPressed: provider.clearFilters,
        child: Text('RESET FILTERS'),
      ),
    ]),
  );
}
```

---

---

# Q4 — Bonus CRUD: Edit, Delete, Status Toggle

## Screenshot 4A: DRY Form — Same Widget for Add AND Edit
**File**: `lib/views/widgets/complaint_form.dart`  
**Lines**: 10 – 18 AND 68 – 94  
**What it shows**: `ComplaintForm` accepts optional `initialComplaint` — when provided it's Edit mode, when null it's Add mode. One widget, two uses.

```dart
// lib/views/widgets/complaint_form.dart  Lines 10–18
class ComplaintForm extends StatefulWidget {
  final Complaint? initialComplaint;  // null = Add, Complaint = Edit
  final VoidCallback? onSuccess;

// Lines 89–94
bool success;
if (isEditing) {
  success = await provider.updateComplaint(newComplaint);  // Edit path
} else {
  success = await provider.addComplaint(newComplaint);     // Add path
}
```

---

## Screenshot 4B: Swipe-to-Delete with Confirmation Dialog
**File**: `lib/views/screens/dashboard_screen.dart`  
**Lines**: 341 – 411  
**What it shows**: `Dismissible` widget triggers swipe-delete, with `confirmDismiss` showing an `AlertDialog` asking "Delete Complaint?" before proceeding.

```dart
// lib/views/screens/dashboard_screen.dart  Lines 341–348
return Dismissible(
  key: Key(complaint.id),
  direction: DismissDirection.horizontal,
  background: _buildSwipeBackground(context, true),
  confirmDismiss: (direction) => _confirmSwipeDelete(context, provider, complaint),
  child: ComplaintCard(complaint: complaint),
);
// AlertDialog Lines 374–411: "Delete Complaint?" with Cancel/Delete buttons
```

---

## Screenshot 4C: CRUD Service — Add, Update, Delete
**File**: `lib/services/firebase_service.dart`  
**Lines**: 43 – 58 AND 148 – 182  
**What it shows**: Firestore `.set()`, `.update()`, and `.delete()` calls inside the singleton service.

```dart
// lib/services/firebase_service.dart  Lines 51–57
await complaintsCollection.doc(complaint.id).set(complaint.toMap());   // CREATE

// Lines 159–161
await complaintsCollection.doc(complaint.id).update(complaint.toMap()); // UPDATE

// Lines 176–178
await complaintsCollection.doc(id).delete();                            // DELETE
```

---

## Screenshot 4D: Firestore fromMap — Reading Data Back
**File**: `lib/models/complaint.dart`  
**Lines**: 42 – 65  
**What it shows**: `Complaint.fromMap()` factory — parses Firestore Timestamp, handles nulls safely.

```dart
// lib/models/complaint.dart  Lines 42–65
factory Complaint.fromMap(Map<String, dynamic> map, String docId) {
  DateTime parsedDate;
  if (map['createdAt'] is Timestamp) {
    parsedDate = (map['createdAt'] as Timestamp).toDate();
  } else {
    parsedDate = DateTime.now();
  }
  return Complaint(
    id: docId,
    title: map['title'] ?? '',
    urgency: map['urgency'] ?? 'Low',
    status: map['status'] ?? 'Pending',
    // ...
  );
}
```

---

---

# Q5 — Reflection Questions (Already answered in `reflection.md`)

**File**: `reflection.md` — open this file and screenshot each answer block.

| Question | Lines in reflection.md |
|----------|------------------------|
| Q1: New widget/feature learned | Lines 9–13 |
| Q2: Was SharedPreferences suitable? | Lines 16–21 |
| Q3: Most debugging challenge | Lines 24–35 |

---

---

# 🔗 GitHub Commits Reference

| Commit | What it fixed | Hash |
|--------|--------------|------|
| Initial commit — full app | All source code | `d8a2fde` |
| Fix: missing firebase_options import | `firebase_service.dart` compile error | `a6de991` |
| Fix: Firebase loads on startup | Complaints now show from DB | `e855b74` |

**Repo URL**: https://github.com/xeeshan-zs/community-complaint-management-app

To view a specific commit on GitHub:  
`https://github.com/xeeshan-zs/community-complaint-management-app/commit/<hash>`

---

*Kafeel Khan | Roll No: 11249 | BSIT-6 Final Lab Exam*
