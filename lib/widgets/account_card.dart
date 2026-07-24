import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const AccountCard({super.key, required this.account, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text(account.accountName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.primary))),
            const SizedBox(height: 12),
            _info(ctx: context, icon: Icons.person_outline, value: account.username, onCopy: () => _copy(context, account.username)),
            const SizedBox(height: 8),
            _info(ctx: context, icon: Icons.lock_outline, value: account.password, onCopy: () => _copy(context, account.password)),
            if (account.note != null && account.note!.isNotEmpty) [const SizedBox(height: 8), _note(context, account.note!)],
            const SizedBox(height: 8),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 1),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _btn(ctx: context, icon: Icons.edit_outlined, label: 'Sửa', color: cs.primary, onTap: onEdit),
              _btn(ctx: context, icon: Icons.delete_outline, label: 'Xóa', color: cs.error, onTap: onDelete),
            ]),
          ]));
  }

  Widget _info({required BuildContext ctx, required IconData icon, required String value, required VoidCallback onCopy}) {
    final cs = Theme.of(ctx).colorScheme;
    return Row(children: [Icon(icon, size: 18, color: cs.onSurfaceVariant), const SizedBox(width: 8), Expanded(child: Text(value, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)), SizedBox(width: 36, height: 36, child: IconButton(onPressed: onCopy, icon: Icon(Icons.copy, size: 16), style: IconButton.styleFrom(foregroundColor: cs.primary))]);
  }

  Widget _note(BuildContext ctx, String n) {
    final cs = Theme.of(ctx).colorScheme;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(Icons.notes_rounded, size: 16, color: cs.onSurfaceVariant), const SizedBox(width: 6), Expanded(child: Text(n, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)))]));
  }

  Widget _btn({required BuildContext ctx, required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: color), const SizedBox(width: 4), Text(label, style: Theme.of(ctx).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600))])));
  }

  void _copy(BuildContext ctx, String t) {
    Clipboard.setData(ClipboardData(text: t));
    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: const Text('윅 Đã copy vào clipboard'), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
  }
}
