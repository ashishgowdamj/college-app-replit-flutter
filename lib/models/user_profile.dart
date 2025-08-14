class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String preferredState;
  final String preferredCourse;
  final bool notifications;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.preferredState = '',
    this.preferredCourse = '',
    this.notifications = true,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? preferredState,
    String? preferredCourse,
    bool? notifications,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      preferredState: preferredState ?? this.preferredState,
      preferredCourse: preferredCourse ?? this.preferredCourse,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'preferredState': preferredState,
        'preferredCourse': preferredCourse,
        'notifications': notifications,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'] ?? '',
        preferredState: j['preferredState'] ?? '',
        preferredCourse: j['preferredCourse'] ?? '',
        notifications: (j['notifications'] ?? true) as bool,
      );
}
