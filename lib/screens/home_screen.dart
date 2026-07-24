import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../widgets/category_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'category_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override void initState() { super.initState(); _loadCategories(); }
  @override void dispose() { _searchController.dispose(); super.dispose(); }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categoryService.getRootCategories();
      setState(() { _categories = categories; _filteredCategories = categories; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.trim().isEmpty) { _filteredCategories = _categories; }
      else { _filteredCategories = _categories.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList(); }
    });
  }

  Future<void> _showCreateCategoryDialog() async {
    final name = await showCategoryDialog(context: context);
    if (name != null) { await _categoryService.createCategory(name: name); _loadCategories(); }
  }

  Future<void> _showEditCategoryDialog(Category cat) async {
    final name = await showCategoryDialog(context: context, initialName: cat.name, isEditing: true);
    if (name != null && name != cat.name) { await _categoryService.updateCategory(id: cat.id!, name: name); _loadCategories(); }
  }

  Future<void> _showDeleteCategoryDialog(Category cat) async {
    final confirmed = await showDeleteConfirmDialog(context: context, title: 'Xoa muc', message: 'Ban co chac muon xoa muc "${cat.name}"?\nTat ca tai khoan trong muc nay cung se bi xoa.');
    if (confirmed) { await _categoryService.deleteCategory(id: cat.id!); _loadCategories(); }
  }

  void _openCategory(Category cat) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryDetailScreen(category: cat))).then((_) => _loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const SizedBox.shrink(), backgroundColor: colorScheme.primaryContainer, elevation: 0),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SearchBar(controller: _searchController, hintText: 'Tim kiem muc...',
            leading: const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.search)),
            trailing: _searchController.text.isNotEmpty ? [IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _filterCategories(''); })] : null,
            onChanged: _filterCategories, elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
        Expanded(child: _filteredCategories.isEmpty ? _buildEmptyState() : ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100), itemCount: _filteredCategories.length,
          itemBuilder: (_, i) => _buildCategoryTile(_filteredCategories[i]))),
      ]),
      floatingActionButton: Padding(padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(onPressed: _showCreateCategoryDialog, icon: const Icon(Icons.add), label: const Text('Tao muc'))),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.folder_open_rounded, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
      const SizedBox(height: 16),
      Text('Chua co muc nao', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
      const SizedBox(height: 8),
      Text('Nhan nut "Tao muc" de bat dau', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
    ]));
  }

  Widget _buildCategoryTile(Category cat) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), elevation: 0, color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.folder_rounded, color: colorScheme.onPrimaryContainer, size: 24)),
        title: Text(cat.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('Tao ngay ${cat.createdAt.day}/${cat.createdAt.month}/${cat.createdAt.year}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (v) { if (v == 'edit') _showEditCategoryDialog(cat); else if (v == 'delete') _showDeleteCategoryDialog(cat); },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Sua')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 12), Text('Xoa', style: TextStyle(color: Colors.red))])),
          ],
        ),
        onTap: () => _openCategory(cat),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
