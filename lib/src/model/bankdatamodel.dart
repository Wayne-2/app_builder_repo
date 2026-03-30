
class UserModel {
  final String userId;
  final String username;
  final String email;
  final String phone;
  final String bankname;
  final String accountnumber;
  final String accountRef;
  final double balance;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.bankname,
    required this.accountnumber,
    required this.accountRef,
    required this.balance,
  });

  /// Primary factory used across the app
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      username: json['username'] ?? 'New User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? 'N/A',
      bankname: json['bank_name'] ?? 'Unavailable',
      accountnumber: json['account_number'] ?? 'N/A',
      accountRef: json['account_ref'] ?? 'N/A',
      balance: json['balance'] ?? 0.0
    );
  }

  /// Alias for code that expects `fromMap`
  factory UserModel.fromMap(Map<String, dynamic> map) =>
      UserModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'bank_name': bankname,
      'account_number': accountnumber,
      'account_ref':accountRef,
      'balance':balance
    };
  }

  @override
  String toString() =>
      'UserModel(user_id: $userId, username: $username, email: $email, bankname:$bankname, accountRef:$accountRef, balance: $balance)';
}