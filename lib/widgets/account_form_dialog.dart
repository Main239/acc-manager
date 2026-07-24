import 'package:flutter/material.dart';

import '../models/account.dart';

/// DŻວ liệu trả về từ AccountFormDialog.
class AccountFormData {
  final String accountName;
  final String username;
  final String password;
  final String? note;

  const AccountFormData({
    required this.accountName,
    required this.username,
    required this.password,
    this.note,
  });
}

/// Dialog / BottomSheet form thêm mới hoặc sửa tài khoản.
/// [existingAccount] được truyền vào khi sửa, null khi tạo mới.
/// Trả về AccountFormData nếu người dùng bẹn Lưu, null neếu h�'y.
Future<AccountFormData?> showAccountFormDialog({
  required BuildContext context,
  Account? existingAccount,
}) async {
  final accountNameController =
      TextEditingController(text: existingAccount?.accountName ?? '');
  final usernameController =
      TextEditingController(text: existingAccount?.username ?? '');
  final passwordController =
      TextEditingController(text: existingAccount?.password ?? '');
  final noteController =
      TextEditingController(text: existingAccount?.note ?? '');

  final isEditing = existingAccount != null;

  return showModalBottomSheet<AccountFormData>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomSheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // └─ Handle indicator └─
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // └─ Title └─
              Text(
                isEditing ? 'SŻa tài khoản' : 'Thêm tài khoản',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // └─ Tâz tài khoản └─
              TextField(
                controller: accountNameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Tên tài khoản',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // └─ Tên đăng nhập └─
              TextField(
                controller: usernameController,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // └─ Mật khẩu └─
              TextField(
                controller: passwordController,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // └─ Ghi chú └─
              TextField(
                controller: noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (không bắt buộc)',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // └─ Nút Lưu └─
              FilledButton(
                onPressed: () {
                  final accountName = accountNameController.text.trim();
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();
                  final note = noteController.text.trim();

                  if (accountName.isEmpty ||
                      username.isEmpty ||
                      password.isEmpty) {
                    ScaffoldMessenger.of(bottomSheetContext).clearSnackBars();
                    ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Vui lòng nhập đầy đủ thông tin bắt buộc'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    return;
                  }

                  Navigator.of(bottomSheetContext).pop(
                    AccountFormData(
                      accountName: accountName,
                      username: username,
                      password: password,
                      note: note.isEmpty ? null : note,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'LƬU',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
