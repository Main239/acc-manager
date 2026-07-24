import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../widgets/account_card.dart';
import '../widgets/account_form_dialog.dart';
import '../widgets/category_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  const CategoryDetailScreen({super.key, required this.category});
  @override State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  List<Account> _accounts = [];
  List<Category> _subCategories = [];
  bool _isLoading = true;

  Category get _cat => widget.category;

  @override void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _accountService.getAccountsByCategory(categoryId: _cat.id!);
      final subs = await _categoryService.getSubCategories(parentId: _cat.id!);
      setState(() { _accounts = accounts; _subCategories = subs; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showAddAccountDialog() async {
    final data = await showAccountFormDialog(context: context);
    if (data != null) {
      await _accountService.createAccount(categoryId: _cat.id!, accountName: data.accountName, username: data.username, password: data.password, note: data.note);
      _loadData();
    }
  }

  Future<void> _showEditAccountDialog(Account account) async {
    final data = await showAccountFormDialog(context: context, existingAccount: account);
    if (data != null) {
      await _accountService.updateAccount(id: account.id!, accountName: data.accountName, username: data.username, password: data.password, note: data.note);
      _loadData();
    }
  }

  Future<void> _toggleLogin(Account account) async {
    await _accountService.toggleLoginStatus(id: account.id!, isLoggedIn: !account.isLoggedIn);
    _loadData();
  }

  Future<void> _showDeleteAccountDialog(Account account) async {
    final confirmed = await showDeleteConfirmDialog(context: context, title: 'Xoa tai khoan', message: 'Ban co chac muon xoa tai khoan "${account.accountName}"?');
    if (confirmed) { await _accountService.deleteAccount(id: account.id!); _loadData(); }
  }

  Future<void> _showCreateSubCategoryDialog() async {
    final name = await showCategoryDialog(context: context);
    if (name != null) {
      await _categoryService.createCategory(name: name, parentId: _cat.id!);
      _loadData();
    }
  }

  Future<void> _showEditSubCategoryDialog(Category sub) async {
    final name = await showCategoryDialog(context: context, initialName: sub.name, isEditing: true);
    if (name != null && name != sub.name) {
      await _categoryService.updateCategory(id: sub.id!, name: name);
      _loadData();
    }
  }

  Future<void> _showDeleteSubCategoryDialog(Category sub) async {
    final confirmed = await showDeleteConfirmDialog(context: context, title: 'Xoa muc', message: 'Ban co chac muon xoa muc "${sub.name}"?');
    if (confirmed) { await _categoryService.deleteCategory(id: sub.id!); _loadData(); }
  }

  void _openSubCategory(Category sub) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryDetailScreen(category: sub))).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasContent = _subCategories.isNotEmpty || _accounts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: colorScheme.primaryContainer, elevation: 0, centerTitle: true,
        title: Text(_cat.name, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : !hasContent ? _buildEmptyState() : _buildContent(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton.small(heroTag: 'add_cat', onPressed: _showCreateSubCategoryDialog, tooltip: 'Tao muc con',
            child: const Icon(Icons.create_new_folder_outlined)),
          const SizedBox(width: 12),
          FloatingActionButton.extended(heroTag: 'add_acc', onPressed: _showAddAccountDialog,
            icon: const Icon(Icons.add), label: const Text('Them tai khoan')),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.folder_open_rounded, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
      const SizedBox(height: 16),
      Text('Chua co gi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
      const SizedBox(height: 8),
      Text('Nhan nut + de them', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
    ]));
  }

  Widget _buildContent() {
    return ListView(padding: const EdgeInsets.only(top: 8, bottom: 100), children: [
      if (_subCategories.isNotEmpty) ...[
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('Muc con', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        ..._subCategories.map((sub) => _buildSubCategoryTile(sub)),
        if (_accounts.isNotEmpty) const Divider(height: 32, indent: 16, endIndent: 16),
      ],
      if (_accounts.isNotEmpty) ...[
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('Tai khoan', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        ..._accounts.map((a) => AccountCard(account: a, onEdit: () => _showEditAccountDialog(a), onDelete: () => _showDeleteAccountDialog(a), onToggleLogin: () => _toggleLogin(a))),
      ],
    ]);
  }

  Widget _buildSubCategoryTile(Category sub) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Icon(Icons.folder_rounded, color: colorScheme.primary, size: 28),
        title: Text(sub.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight. w600)),
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (v) { if (v == 'edit') _showEditSubCategoryDialog(sub); else if (v == 'delete') _showDeleteSubCategoryDialog(sub); },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outline, size: 18), SizedBox(width: 8), Text('Sua')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Xoa', style: TextStyle(color: Colors.red))])),
          ],
        ),
        onTap: () => _openSubCategory(sub),
      ),
    );
  }
}
