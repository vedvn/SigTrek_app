class UserProfile {
  final String uid;
  final String email;
  final String? name;
  final bool isProfileComplete;
  final int emergencyContactsCount;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.isProfileComplete = false,
    this.emergencyContactsCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'isProfileComplete': isProfileComplete,
      'emergencyContactsCount': emergencyContactsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      isProfileComplete: map['isProfileComplete'] ?? false,
      emergencyContactsCount: map['emergencyContactsCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
