import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/account.dart';

/// Card hiển thị thông tin một tài khoản.
class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountCard({
    super.key,
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Tên tài khoản (căn giữa, chữ lớn, đậm) ──
            Center(
              child: Text(
                account.accountName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // ── Divider ──
            Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              height: 1,
            ),

            const SizedBox(height: 16),

            // ── Row: Tên đăng nhập ──
            _buildInfoRow(
              context: context,
              label: 'Tên đăng nhập',
              value: account.username,
              icon: Icons.person_outline,
              onCopy: () => _copyToClipboard(context, account.username),
            ),

            const SizedBox(height: 14),

            // ── Row: Mật khẩu ──
            _buildInfoRow(
              context: context,
              label: 'Mật khẩu',
              value: account.password,
              icon: Icons.lock_outline,
              onCopy: () => _copyToClipboard(context, account.password),
            ),

            // ── Ghi chú (chỉ hiển thị nếu có) ──
            if (account.note != null && account.note!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildNoteRow(context, account.note!),
            ],

            const SizedBox(height: 16),

            // ── Divider ──
            Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              height: 1,
            ),

            const SizedBox(height: 8),

            // ── Row: Nút Sửa và Xóa ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút Sửa
                _buildActionButton(
                  context: context,
                  icon: Icons.edit_outlined,
                  label: 'Sửa',
                  color: colorScheme.primary,
                  onTap: onEdit,
                ),

                // Nút Xóa
                _buildActionButton(
                  context: context,
                  icon: Icons.delete_outline,
                  label: 'Xóa',
                  color: colorScheme.error,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Row hiển thị label + value + nút copy.
  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Icon
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),

        // Label
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),

        // Value
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Nút Copy
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Copy $label',
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Row hiển thị ghi chú.
  Widget _buildNoteRow(BuildContext context, String note) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notes_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nút hành động (Sửa / Xóa).
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Copy text vào clipboard và hiển thị SnackBar.
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Đã copy vào clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
