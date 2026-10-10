// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/extensions.dart';
import 'package:flutter_catat_stok/core/utils/smooth_page_route.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/product/presentation/screens/manage_category_screen.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../module/auth/presentation/provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Akun Toko?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: const Text(
          'Anda perlu masuk kembali untuk mengakses data stok inventaris toko Anda.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.stockOut,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final products = context.watch<ProductProvider>().products;
    final categories = context.watch<ProductProvider>().categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Akun',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search_rounded, size: 22),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Banner (Match Stitch 01_akun_modern)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: AppColors.stockIn),
                        SizedBox(width: 6),
                        Text(
                          'Data Tersimpan Lokal',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      '🔄 Sinkron: Realtime',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // User Profile Main Card (Match Stitch 01_akun_modern)
              AppCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user?.name.initials ?? 'BS',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user?.name ?? 'Pak Bambang Sutrisno',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'PEMILIK UTAMA',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Toko Kelontong Berkah',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? 'bambang.warungjaya@gmail.com',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3 Metric Stat Box Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Katalog Aktif', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  '${products.length} Item',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Kategori', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  '${categories.length} Jenis',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Presensi Toko', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                SizedBox(height: 2),
                                Text('12 Hari', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Menu Section 1: PENGATURAN WARUNG
              _buildSectionHeader('PENGATURAN WARUNG', 'Operasional'),
              AppCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: Column(
                  children: [
                    _buildSettingTile(
                      icon: Icons.storefront_outlined,
                      title: 'Profil Warung & Alamat',
                      subtitle: 'Jl. Kebon Sirih No. 14, RT 03/05',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildSettingTile(
                      icon: Icons.grid_view_outlined,
                      title: 'Kelola Kategori Barang',
                      subtitle: '${categories.length} Kategori terdaftar',
                      badge: '${categories.length} Kategori',
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute(page: const ManageCategoryScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildSettingTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'Satuan Barang Dagangan',
                      subtitle: 'Pcs, Box, Bungkus, Kg, Liter',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Menu Section 2: OPERASIONAL & CADANGAN
              _buildSectionHeader('OPERASIONAL & CADANGAN', 'Keandalan'),
              AppCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: Column(
                  children: [
                    _buildSettingTile(
                      icon: Icons.file_download_outlined,
                      title: 'Ekspor Laporan Warung',
                      subtitle: 'Buku Stok, Nota Masuk (Excel / PDF)',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Simulasi ekspor laporan stok warung')),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildSettingTile(
                      icon: Icons.cloud_sync_outlined,
                      title: 'Cadangkan & Pulihkan Data',
                      subtitle: 'Arsip mandiri ke Cloud / Lokal',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout Button (Match Stitch 01_akun_modern)
              ElevatedButton.icon(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stockOutBg,
                  foregroundColor: AppColors.stockOut,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Keluar dari Akun Toko',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),

              // Footer App Version Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⚙️ Stok Saya v1.4.2',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dibuat khusus UMKM Warung Indonesia • Data dienkripsi lokal',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            badge,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
