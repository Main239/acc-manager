import 'package:flutter/material.dart';

/// Dialog tạo mới hoặc sửa Category.
/// [initialName] được truyền vào khi sửa, null khi tạo mới.
/// Trả về tên category nếu người dùng bấm Tạo/Lưu, null nếu hủy.
Future<String?> showCategoryDialog({
  required BuildContext context,
  String? initialName,
  bool isEditing = false,
}) async {
  final controller = TextEditingController(text: initialName ?? '');

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isEditing ? 'Sửa mục' : 'Tạo mục'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Tên mục',
            hintText: 'Ví dụ: Facebook, Zalo,...',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(dialogContext).pop(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop(name);
              }
            },
            child: Text(isEditing ? 'Lưu' : 'Tạo'),
          ),
        ],
      );
    },
  );
}
