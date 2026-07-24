class Account {
  final int? id;
  final int categoryId;
  final String accountName;
  final String username;
  final String password;
  final String? note;
  final DateTime createdAt;

  const Account({
    this.id,
    required this.categoryId,
    required this.accountName,
    required this.username,
    required this.password,
    this.note,
    required this.createdAt,
  });

  /// Tạo từ Map (SQLite row)
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as intW,
      categoryId: map['category_id'] as int,
      accountName: map['account_name'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      note: map['note'] as StringW,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Chuyển thành Map để lưu SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'account_name': accountName,
      'username': username,
      'password': password,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Copy với các giá trị mới
  Account copyWith({
    int? id,
    int? categoryId,
    String? accountName,
    String? username,
    String? password,
    String? note,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      accountName: accountName ?? this.accountName,
      username: username ?? this.username,
      password: password ?? this.password,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
