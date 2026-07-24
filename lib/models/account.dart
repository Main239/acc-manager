class Account {
  final int? id;
  final int categoryId;
  final String accountName;
  final String username;
  final String password;
  final String? note;
  final bool isLoggedIn;
  final DateTime createdAt;

  const Account({
    this.id,
    required this.categoryId,
    required this.accountName,
    required this.username,
    required this.password,
    this.note,
    this.isLoggedIn = false,
    required this.createdAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      accountName: map['account_name'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      note: map['note'] as String?,
      isLoggedIn: (map['is_logged_in'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'account_name': accountName,
      'username': username,
      'password': password,
      'note': note,
      'is_logged_in': isLoggedIn ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Account copyWith({
    int? id, int? categoryId, String? accountName, String? username,
    String? password, String? note, bool? isLoggedIn, DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      accountName: accountName ?? this.accountName,
      username: username ?? this.username,
      password: password ?? this.password,
      note: note ?? this.note,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
