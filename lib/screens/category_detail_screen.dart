import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../services/account_service.dart';
import '../widgets/account_card.dart';
import '../widgets/account_form_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  const CategoryDetailScreen({super.key, required this.category});
  @override State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final AccountService _accountService = AccountService();
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override void initState() { super.initState(); _loadAccounts(); }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _accountService.getAccountsByCategory(categoryId: widget.category.id!);
      setState(() { _accounts = accounts; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  Future<void> _showAddAccountDialog() async {
    final data = await showAccountFormDialog(context: context);
    if (data != null) {
      await _accountService.createAccount(categoryId: widget.category.id!, accountName: data.accountName, username: data.username, password: data.password, note: data.note);
      _loadAccounts();
    }
  }

  Future<void> _showEditAccountDialog(Account account) async {
    final data = await showAccountFormDialog(context: context, existingAccount: account);
    if (data != null) {
      await _accountService.updateAccount(id: account.id!, accountName: data.accountName, username: data.username, password: data.password, note: data.note);
      _loadAccounts();
    }
  }

  Future<void> _showDeleteAccountDialog(Account account) async {
    final confirmed = await showDeleteConfirmDialog(context: context, title: 'Xóa tài khoản', message: 'Bạn có chắc muốn xóa tài khoản "${account.accountName}"?');
    if (confirmed) { await _accountService.deleteAccount(id: account.id!); _loadAccounts(); }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()), backgroundColor: colorScheme.primaryContainer, elevation: 0, centerTitle: true, title: Text(widget.category.name, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer))),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _accounts.isEmpty ? _buildEmptyState() : _buildAccountsList(),
      floatingActionButton: Padding(padding: const EdgeInsets.only(bottom: 16), child: FloatingActionButton.extended(onPressed: _showAddAccountDialog, icon: const Icon(Icons.add), label: const Text('Thêm tài khoản'))),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_off_rounded, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)), const SizedBox(height: 16), Text('Chưa có tài khoản nào', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7))), const SizedBox(height: 8), Text('Nhấn nút + để thêm tài khoản', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)))]));
  }

  Widget _buildAccountsList() {
    return ListView.builder(padding: const EdgeInsets.only(top: 8, bottom: 100), itemCount: _accounts.length, itemBuilder: (c, i) { final a = _accounts[i]; return AccountCard(account: a, onEdit: () => _showEditAccountDialog(a), onDelete: () => _showDeleteAccountDialog(a)); });
  }
}
