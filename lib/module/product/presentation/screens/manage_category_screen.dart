// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/utils/smooth_page_route.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';

class ManageCategoryScreen extends StatefulWidget {
  final PickCategoryType type;

  const ManageCategoryScreen({super.key, this.type = PickCategoryType.manage});

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  late final ProductProvider _productProvider = context.read<ProductProvider>();

  void _showAddEditCategoryModal({
    required List<CategoryItem> categories,
    CategoryItem? category,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                category != null ? 'Edit Kategori' : 'Tambah Kategori Baru',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nama Kategori *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Aksesoris HP',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    if (category != null) {
                      final idx = categories.indexWhere(
                        (c) => c.id == category.id,
                      );
                      if (idx != -1) {
                        _productProvider.updateCategoryName(
                          category: CategoryItem(
                            id: category.id,
                            name: nameController.text.trim(),
                            products: category.products,
                          ),
                        );
                      }
                    } else {
                      _productProvider.addCategory(name: nameController.text.trim());
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(
                  category != null ? 'Simpan Perubahan' : 'Tambah Kategori',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          (widget.type == PickCategoryType.initial)
              ? 'Buat Kategori Awal'
              : 'Kelola Kategori',
        ),
        automaticallyImplyLeading: widget.type != PickCategoryType.initial,
        leading: (widget.type == PickCategoryType.initial)
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manage_category_fab',
        onPressed: () => _showAddEditCategoryModal(categories: _productProvider.categories),
        backgroundColor: AppColors.primary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Kategori Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _productProvider.getCategories(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Info
              AppCard(
                backgroundColor: AppColors.primaryLight,
                borderColor: AppColors.border,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori Produk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kelompokkan barang agar lebih rapi & mudah dicari.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List of Categories
              Selector<ProductProvider, List<CategoryItem>>(
                selector: (_, provider) => provider.categories,
                builder: (context, categoryList, _) {
                  if (categoryList.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.all(24),
                      child: const Center(
                        child: Text(
                          'Belum ada kategori diset. Klik tombol + Kategori Baru.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cat = categoryList[index];
                      return AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${cat.productCount} Produk terdaftar',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () => _showAddEditCategoryModal(
                                categories: categoryList,
                                category: cat,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.stockOut,
                                size: 18,
                              ),
                              onPressed: () {
                                if (cat.productCount > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kategori ini masih memiliki produk. Hapus produk terlebih dahulu sebelum menghapus kategori.',
                                      ),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                  return;
                                }
                                
                                _productProvider.deleteCategory(cat.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              if (widget.type == PickCategoryType.initial) ...[
                const SizedBox(height: 24),
                Center(
                  child: Consumer<ProductProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: () {
                          if (provider.categories.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Buat setidaknya 1 kategori terlebih dahulu.',
                                ),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).pushReplacement(
                            SmoothPageRoute(
                              page: const MainNavigationScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Lanjut ke Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
