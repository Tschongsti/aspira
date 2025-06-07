class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

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
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Factory-Methode zum Erstellen aus einem Firestore-Dokument
  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  /// Umwandlung zurück für Firestore-Speicherung
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}