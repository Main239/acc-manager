import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleLogin;
  final VoidCallback onMove;

  const AccountCard({
    super.key,
    required this.account,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleLogin,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLogged = account.isLoggedIn;
    final borderColor = isLogged ? Colors.green : cs.outlineVariant.withValues(alpha: 0.5);
    final bgColor = isLogged ? Colors.green.withValues(alpha: 0.06) : cs.surface;
    final accent = isLogged ? Colors.green : cs.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: isLogged ? 1.5 : 0.5),
      ),
      elevation: 0,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                account.accountName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context: context,
              icon: Icons.person_outline,
              value: account.username,
              onCopy: () => Clipboard.setData(ClipboardData(text: account.username)),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context: context,
              icon: Icons.lock_outline,
              value: account.password,
              onCopy: () => Clipboard.setData(ClipboardData(text: account.password)),
            ),
            if (account.note != null && account.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildNoteRow(context, account.note!),
            ],
            const SizedBox(height: 8),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(context: context, icon: Icons.edit_outlined, label: 'Sua', color: cs.primary, onTap: onEdit),
                _buildActionButton(context: context, icon: Icons.drive_file_move_outlined, label: 'Chuyen', color: Colors.orange, onTap: onMove),
                _buildToggleButton(isLogged, onToggleLogin),
                _buildActionButton(context: context, icon: Icons.delete_outline, label: 'Xoa', color: cs.error, onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool isLogged, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLogged ? Colors.green : Colors.red.withValues(alpha: 0.3),
          border: Border.all(width: 2.5, color: isLogged ? Colors.green : Colors.red),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String value,
    required VoidCallback onCopy,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 16),
            style: IconButton.styleFrom(foregroundColor: cs.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteRow(BuildContext context, String note) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.notes_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
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
}
