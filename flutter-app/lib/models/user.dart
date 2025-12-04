class User {
  final int? id;
  final String? name;
  final String? mobile;
  final String? email;
  final String? role;
  final String? token;
  final bool? isActive;
  final String? gender;

  User({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.role,
    this.token,
    this.isActive,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
      isActive: json['isActive'] as bool?,
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'role': role,
      'token': token,
      'isActive': isActive,
      'gender': gender,
    };
  }
}

