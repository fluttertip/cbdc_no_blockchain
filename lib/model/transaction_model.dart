class Transaction {
  final String id;
  final String sender; // userId
  final String receiver; // userId
  final double amount;
  final String status;
  final String transactionType;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.status,
    required this.transactionType,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      status: json['status'] ?? '',
      transactionType: json['transactionType'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'receiver': receiver,
      'amount': amount,
      'status': status,
      'transactionType': transactionType,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
