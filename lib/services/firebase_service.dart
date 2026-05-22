import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';

class FirebaseService {
  // Private Constructor for Singleton pattern
  FirebaseService._privateConstructor();

  static final FirebaseService instance = FirebaseService._privateConstructor();

  // Local memory-based storage for transparent offline fallback / demo mode
  final List<Complaint> _mockStorage = [];
  final StreamController<List<Complaint>> _mockStreamController = StreamController<List<Complaint>>.broadcast();

  bool _forceOffline = true;

  bool get forceOffline => _forceOffline;

  set forceOffline(bool value) {
    _forceOffline = value;
  }

  // Helper getter to safely check if Firebase is initialized
  bool get isFirebaseInitialized {
    if (_forceOffline) return false;
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> initializeFirebaseDynamic() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  // Insert a new complaint
  Future<void> addComplaint(Complaint complaint) async {
    if (!isFirebaseInitialized) {
      // Offline fallback: insert into local list and stream it
      _mockStorage.insert(0, complaint); // Insert at top
      _mockStreamController.add(List.from(_mockStorage));
      return;
    }

    try {
      final CollectionReference complaintsCollection =
          FirebaseFirestore.instance.collection('complaints');
      await complaintsCollection.doc(complaint.id).set(complaint.toMap());
    } catch (e) {
      throw Exception('Failed to submit complaint: $e');
    }
  }

  // Fetch complaints in real-time
  Stream<List<Complaint>> getComplaintsStream() {
    if (!isFirebaseInitialized) {
      // Seed high-quality mock complaints matching our dropdown types for desktop demo
      if (_mockStorage.isEmpty) {
        _seedMockData();
      }
      // Delayed trigger to simulate network loading states
      Timer(const Duration(milliseconds: 800), () {
        if (!_mockStreamController.isClosed) {
          _mockStreamController.add(List.from(_mockStorage));
        }
      });
      return _mockStreamController.stream;
    }

    return FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Complaint.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  void _seedMockData() {
    _mockStorage.addAll([
      Complaint(
        id: 'mock-1',
        title: 'Street Light Blinking',
        description: 'The street light right outside House #459 corner has been blinking continuously for three nights, creating a serious security hazard and nuisance.',
        residentName: 'Kamran Shah',
        type: 'Street Light Damage',
        urgency: 'Medium',
        resolutionDays: 3,
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Complaint(
        id: 'mock-2',
        title: 'Severe Water Pipe Leakage',
        description: 'Burst main water connection pipe on Sector-G main road. Fresh clean water is leaking out at high velocity, flooding the nearby sidewalk.',
        residentName: 'Ayesha Bibi',
        type: 'Water Leakage',
        urgency: 'High',
        resolutionDays: 1,
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Complaint(
        id: 'mock-3',
        title: 'Main Transformer Sparks',
        description: 'Occasional sparks visible from the main pole transformer whenever the wind blows. It could lead to a localized grid blackout.',
        residentName: 'Hamza Khan',
        type: 'Electricity Failure',
        urgency: 'High',
        resolutionDays: 2,
        status: 'Resolved',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Complaint(
        id: 'mock-4',
        title: 'Garbage Dump Overflow',
        description: 'The municipal waste bins in Sector-B have not been cleared since last Friday. Stray animals are scattering trash across the street.',
        residentName: 'Zainab Ahmed',
        type: 'Garbage Collection',
        urgency: 'Low',
        resolutionDays: 4,
        status: 'Resolved',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Complaint(
        id: 'mock-5',
        title: 'Suspicious Midnight Activity',
        description: 'Unidentified individuals spotted roaming the back alley of Sector-F parks after 1 AM. Requesting increased night security patrols.',
        residentName: 'Daniyal Ali',
        type: 'Security Issue',
        urgency: 'High',
        resolutionDays: 2,
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ]);
  }

  // Update an existing complaint
  Future<void> updateComplaint(Complaint complaint) async {
    if (!isFirebaseInitialized) {
      final index = _mockStorage.indexWhere((c) => c.id == complaint.id);
      if (index != -1) {
        _mockStorage[index] = complaint;
        _mockStreamController.add(List.from(_mockStorage));
      }
      return;
    }

    try {
      final CollectionReference complaintsCollection =
          FirebaseFirestore.instance.collection('complaints');
      await complaintsCollection.doc(complaint.id).update(complaint.toMap());
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  // Delete a complaint
  Future<void> deleteComplaint(String id) async {
    if (!isFirebaseInitialized) {
      _mockStorage.removeWhere((c) => c.id == id);
      _mockStreamController.add(List.from(_mockStorage));
      return;
    }

    try {
      final CollectionReference complaintsCollection =
          FirebaseFirestore.instance.collection('complaints');
      await complaintsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete complaint: $e');
    }
  }
}
