class Memory {
  final String id;
  final String photoUrl;
  final String briefDescription;
  final String description;
  final DateTime createdAt;
  final String contributorId;

  Memory({
    required this.id,
    required this.photoUrl,
    required this.briefDescription,
    required this.description,
    required this.createdAt,
    required this.contributorId,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'],
      photoUrl: json['photo_url'],
      briefDescription: json['brief_description'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      contributorId: json['contributor_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_url': photoUrl,
      'brief_description': briefDescription,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'contributor_id': contributorId,
    };
  }
}

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MemoryDetailScreen(
      memory: memory,
      authService: AuthService(),
    ),
  ),
);