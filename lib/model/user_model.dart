class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String kycStatus;
  final bool kycVerified;
  final double balance;
  final String? pin;
  final bool? biometricEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'user',
    this.kycStatus = 'not_submitted',
    this.kycVerified = false,
    this.balance = 0.0,
    this.pin,
    this.biometricEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      kycStatus: json['kycStatus'] ?? 'not_submitted',
      kycVerified: json['kycVerified'] ?? false,
      balance: json['balance'] != null
          ? double.parse(json['balance'].toString())
          : 0.0,
      pin: json['pin'],
      biometricEnabled: json['biometricEnabled'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'kycStatus': kycStatus,
      'kycVerified': kycVerified,
      'balance': balance,
      'pin': pin,
      'biometricEnabled': biometricEnabled,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? kycStatus,
    bool? kycVerified,
    double? balance,
    String? pin,
    bool? biometricEnabled,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      kycStatus: kycStatus ?? this.kycStatus,
      kycVerified: kycVerified ?? this.kycVerified,
      balance: balance ?? this.balance,
      pin: pin ?? this.pin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
