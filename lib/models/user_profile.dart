import 'dart:convert';
import 'package:flutter/material.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.visitedScreens,
    this.isDirty = true,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> visitedScreens;
  final bool isDirty;
  final DateTime updatedAt;

  factory UserProfile.empty(String id, String email) {
    return UserProfile(
      id: id,
      email: email,
      displayName: '',
      photoUrl: null,
      visitedScreens: [],
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? visitedScreens,
    bool? isDirty,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      visitedScreens: visitedScreens ?? this.visitedScreens,
      isDirty: isDirty ?? this.isDirty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserProfile.fromLocalMap(Map<String, dynamic> map) {
    try {
      final decodedScreens = map['visitedScreens'] == null
          ? <String>[]
          : List<String>.from(jsonDecode(map['visitedScreens']) as List<dynamic>);
          
      return UserProfile(
        id: map['id'],
        email: map['email'],
        displayName: map['displayName'],
        photoUrl: map['photoUrl'],
        visitedScreens: decodedScreens,
        isDirty: (map['isDirty'] ?? 1) == 1,
        updatedAt: DateTime.parse(map['updatedAt']),
      );
    } catch (e) {
      debugPrint('❌ Fehler beim Parsen von visitedScreens: ${map['visitedScreens']}');
      rethrow;
    }
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'visitedScreens': jsonEncode(visitedScreens),
      'isDirty': isDirty ? 1 : 0,
      'updatedAt': updatedAt.toLocal().toIso8601String(),
    };
  }
}