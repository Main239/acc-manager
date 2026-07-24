import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import '../widgets/category_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'category_detail_screen.dart';

/// Trang chủ - hiển thị danh sách các mục (categories).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load tất cả categories từ DB.
  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
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

  /// Tìm kiếm categories.
  void _filterCategories(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  /// Mở dialog tạo category mới.
  Future<void> _showCreateCategoryDialog() async {
    final name = await showCategoryDialog(context: context);

    if (name != null) {
      await _categoryService.createCategory(name: name);
      _loadCategories();
    }
  }

  /// Mở dialog sửa tên category.
  Future<void> _showEditCategoryDialog(Category category) async {
    final name = await showCategoryDialog(
      context: context,
      initialName: category.name,
      isEditing: true,
    );

    if (name != null && name != category.name) {
      await _categoryService.updateCategory(id: category.id!, name: name);
      _loadCategories();
    }
  }

  /// Xác nhận và xóa category.
  Future<void> _showDeleteCategoryDialog(Category category) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      title: 'Xóa mục',
      message: 'Bạn có chắc muốn xóa mục "${category.name}"?
Tất cả tài khoản trong mục này cũng sẽ bị xóa.',
    );

    if (confirmed) {
      await _categoryService.deleteCategory(id: category.id!);
      _loadCategories();
    }
  }

  /// Mở màn hình chi tiết category.
  void _openCategoryDetail(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(category: category),
      ),
    ).then((_) {
      // Khi quay lại, refresh dữ liệu
      _loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản Lý Tài Khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        backgroundColor: colorScheme.primaryContainer,
        elevation: 0,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Thanh tìm kiếm ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Tìm kiếm mục...',
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.search),
                    ),
                    trailing: _searchController.text.isNotEmpty
                        ? [
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterCategories('');
                              },
                            ),
                          ]
                        : null,
                    onChanged: _filterCategories,
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor:
                        WidgetStatePropertyAll(colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                // ── Danh sách categories ──
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 100, // Để không bị FAB che
                          ),
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            return _buildCategoryTile(category, index);
                          },
                        ),
                ),
              ],
            ),

      // ── FAB: Tạo mục ──
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: _showCreateCategoryDialog,
          icon: const Icon(Icons.add),
          label: const Text('Tạo mục'),
        ),
      ),
    );
  }

  /// Widget hiển thị khi không có category nào.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 80,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có mục nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút "Tạo mục" để bắt đầu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }

  /// Mỗi category được hiển thị như một ListTile với icon folder.
  Widget _buildCategoryTile(Category category, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.folder_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          title: Text(
            category.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            'Tạo ngày ${_formatDate(category.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditCategoryDialog(category);
              } else if (value == 'delete') {
                _showDeleteCategoryDialog(category);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Sửa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _openCategoryDetail(category),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// Format DateTime thành chuỗi ngày tháng.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
