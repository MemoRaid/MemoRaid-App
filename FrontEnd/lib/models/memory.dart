// lib/models/memory.dart
class Memory {
  final String id;
  final String photoUrl;
  final String briefDescription;
  final String description;
  final DateTime createdAt;
  final String patientId;

  Memory({
    required this.id,
    required this.photoUrl,
    required this.briefDescription,
    required this.description,
    required this.createdAt,
    required this.patientId,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'],
      photoUrl: json['photo_url'],
      briefDescription: json['brief_description'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      patientId: json['patient_id'],
    );
  }
}