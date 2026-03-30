class UserServiceModel {
  final String id;
  final String username;
  final String serviceUsed;
  final String serviceId;
  final double amount;
  final DateTime createdAt;

  UserServiceModel({
    required this.id,
    required this.username,
    required this.serviceUsed,
    required this.serviceId,
    required this.amount,
    required this.createdAt,
  });

  factory UserServiceModel.fromJson(Map<String, dynamic> json) {
    return UserServiceModel(
      id: json['id'],
      username: json['username'],
      serviceUsed: json['service_used'],
      serviceId: json['service_id'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
