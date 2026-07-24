import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../services/account_service.dart';
import '../widgets/account_card.dart';
import '../widgets/account_form_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';

/// Màn hình chi tiết một Category - hiển thị danh sách tài khoản.
class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final AccountService _accountService = AccountService();

  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  /// Load tất cả accounts thuộc category này.
  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    try {
      final accounts =
          await _accountService.getAccountsByCategory(categoryId: widget.category.id!);
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  /// Mở form thêm tài khoản.
  Future<void> _showAddAccountDialog() async {
    final data = await showAccountFormDialog(context: context);

    if (data != null) {
      await _accountService.createAccount(
        categoryId: widget.category.id!,
        accountName: data.accountName,
        username: data.username,
        password: data.password,
        note: data.note,
      );
      _loadAccounts();
    }
  }

  /// Mở form sửa tài khoản.
  Future<void> _showEditAccountDialog(Account account) async {
    final data = await showAccountFormDialog(
      context: context,
      existingAccount: account,
    );

    if (data != null) {
      await _accountService.updateAccount(
        id: account.id!,
        accountName: data.accountName,
        username: data.username,
        password: data.password,
        note: data.note,
      );
      _loadAccounts();
    }
  }

  /// Xác nhận và xóa tài khoản.
  Future<void> _showDeleteAccountDialog(Account account) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      title: 'Xóa tài khoản',
      message: 'Bạn có chắc muốn xóa tài khoản "${account.accountName}"?',
    );

    if (confirmed) {
      await _accountService.deleteAccount(id: account.id!);
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ── AppBar với tên Category ──
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        actions: [
          // Nút thêm tài khoản trên AppBar
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: _showAddAccountDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm tài khoản'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? _buildEmptyState()
              : _buildAccountsList(),
    );
  }

  /// Widget hiển thị khi không có tài khoản nào.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_rounded,
            size: 80,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tài khoản nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn "Thêm tài khoản" để bắt đầu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddAccountDialog,
            icon: const Icon(Icons.add),
            label: const Text('Thêm tài khoản'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sách tài khoản dưới dạng AnimatedList.
  Widget _buildAccountsList() {
    final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

    return AnimatedList(
      key: listKey,
      initialItemCount: _accounts.length,
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemBuilder: (context, index, animation) {
        final account = _accounts[index];
        return _buildAnimatedAccountCard(account, animation);
      },
    );
  }

  /// Card với animation fade + slide.
  Widget _buildAnimatedAccountCard(Account account, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
      child: FadeTransition(
        opacity: animation,
        child: AccountCard(
          account: account,
          onEdit: () => _showEditAccountDialog(account),
          onDelete: () => _showDeleteAccountDialog(account),
        ),
      ),
    );
  }
}
