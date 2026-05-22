import 'dart:async';
import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/firebase_service.dart';

class ComplaintProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  List<Complaint> _allComplaints = [];
  StreamSubscription<List<Complaint>>? _complaintsSubscription;

  // Filter States
  String _selectedType = 'All';
  String _selectedUrgency = 'All';
  String _selectedStatus = 'All';

  // Loading and Error States
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _hasFirebaseError = false;

  // Getters
  List<Complaint> get allComplaints => _allComplaints;
  String get selectedType => _selectedType;
  String get selectedUrgency => _selectedUrgency;
  String get selectedStatus => _selectedStatus;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get hasFirebaseError => _hasFirebaseError;
  bool get isOfflineMode => _firebaseService.forceOffline;

  // Constructor
  ComplaintProvider() {
    _initComplaintsStream();
  }

  // Subscribe to real-time changes
  void _initComplaintsStream() {
    _isLoading = true;
    _errorMessage = null;
    _hasFirebaseError = false;
    notifyListeners();

    _complaintsSubscription?.cancel();
    _complaintsSubscription = _firebaseService.getComplaintsStream().listen(
      (complaints) {
        _allComplaints = complaints;
        _isLoading = false;
        _errorMessage = null;
        _hasFirebaseError = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _hasFirebaseError = true;
        _errorMessage = 'Database sync failed: ${error.toString()}';
        notifyListeners();
      },
    );
  }

  // Reload/Retry connection
  void retryConnection() {
    _initComplaintsStream();
  }

  // Toggle force offline mode
  void setForceOffline(bool value) {
    _firebaseService.forceOffline = value;
    _initComplaintsStream();
  }

  // Lazy initialize Firebase and enable cloud sync dynamically
  Future<bool> enableCloudSync() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _hasFirebaseError = false;
      notifyListeners();

      await _firebaseService.initializeFirebaseDynamic();
      _firebaseService.forceOffline = false;
      _initComplaintsStream();
      return true;
    } catch (e) {
      _isLoading = false;
      _hasFirebaseError = true;
      _errorMessage = e.toString();
      _firebaseService.forceOffline = true;
      _initComplaintsStream();
      notifyListeners();
      return false;
    }
  }

  // Set Filter Values
  void setFilterType(String value) {
    _selectedType = value;
    notifyListeners();
  }

  void setFilterUrgency(String value) {
    _selectedUrgency = value;
    notifyListeners();
  }

  void setFilterStatus(String value) {
    _selectedStatus = value;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedType = 'All';
    _selectedUrgency = 'All';
    _selectedStatus = 'All';
    notifyListeners();
  }

  // Retrieve filtered complaints list
  List<Complaint> get filteredComplaints {
    return _allComplaints.where((complaint) {
      final matchesType = _selectedType == 'All' || complaint.type == _selectedType;
      final matchesUrgency = _selectedUrgency == 'All' || complaint.urgency == _selectedUrgency;
      final matchesStatus = _selectedStatus == 'All' || complaint.status == _selectedStatus;
      return matchesType && matchesUrgency && matchesStatus;
    }).toList();
  }

  // Dashboard Stats derived from all active/filtered complaints (DRY)
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

  // CRUD Operations wrapped for State notifications
  Future<bool> addComplaint(Complaint complaint) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.addComplaint(complaint);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComplaint(Complaint complaint) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.updateComplaint(complaint);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComplaint(String id) async {
    try {
      await _firebaseService.deleteComplaint(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleComplaintStatus(Complaint complaint) async {
    final updatedComplaint = complaint.copyWith(
      status: complaint.status == 'Pending' ? 'Resolved' : 'Pending',
    );
    await updateComplaint(updatedComplaint);
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    super.dispose();
  }
}
