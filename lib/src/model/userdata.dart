class UserProfile {
  final String userId;
  final String username;
  final String email;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'],
      username: map['username'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
    };
  }
}
