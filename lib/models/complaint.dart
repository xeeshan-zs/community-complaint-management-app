import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Convert to Map for database insertions
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'residentName': residentName,
      'type': type,
      'urgency': urgency,
      'resolutionDays': resolutionDays,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Parse from Firestore DocumentSnapshot or Map
  factory Complaint.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Complaint(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      residentName: map['residentName'] ?? '',
      type: map['type'] ?? 'General',
      urgency: map['urgency'] ?? 'Low',
      resolutionDays: map['resolutionDays'] is int
          ? map['resolutionDays']
          : int.tryParse(map['resolutionDays']?.toString() ?? '1') ?? 1,
      status: map['status'] ?? 'Pending',
      createdAt: parsedDate,
    );
  }

  // Create a copy of the complaint with updated fields
  Complaint copyWith({
    String? title,
    String? description,
    String? residentName,
    String? type,
    String? urgency,
    int? resolutionDays,
    String? status,
    DateTime? createdAt,
  }) {
    return Complaint(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      residentName: residentName ?? this.residentName,
      type: type ?? this.type,
      urgency: urgency ?? this.urgency,
      resolutionDays: resolutionDays ?? this.resolutionDays,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
