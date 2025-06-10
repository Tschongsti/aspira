class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isDirty = true,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isDirty;
  final DateTime updatedAt;

  factory UserProfile.empty(String id, String email) {
    return UserProfile(
      id: id,
      email: email,
      displayName: '',
      photoUrl: null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isDirty,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isDirty: isDirty ?? this.isDirty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory-Methode zum Erstellen aus einem Firestore-Dokument
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      isDirty: (map['isDirty'] ?? 1) == 1,
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Umwandlung zurück für Firestore-Speicherung
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isDirty': isDirty ? 1 : 0,
      'updatedAt': updatedAt.toLocal().toIso8601String(),
    };
  }
}