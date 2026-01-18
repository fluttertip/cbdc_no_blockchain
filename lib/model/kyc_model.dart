class KYC {
  final String id;
  final String userId;
  final String idType;
  final String idNumber;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;

  KYC({
    required this.id,
    required this.userId,
    required this.idType,
    required this.idNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rejectionReason,
  });

  factory KYC.fromJson(Map<String, dynamic> json) {
    return KYC(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      idType: json['idType'] ?? '',
      idNumber: json['idNumber'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'idType': idType,
      'idNumber': idNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }
}