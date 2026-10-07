import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../module/auth/presentation/provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Anda perlu masuk kembali untuk mengakses data stok inventaris Anda.',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Akun & Pengaturan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: const Text(
                      'ST',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stok Saya Retail',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'owner@stoksaya.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Owner / Admin Utuk',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Store & Account Settings Section
            _buildSectionHeader('Toko & Akun'),
            _buildSettingCard([
              _buildSettingTile(
                icon: Icons.store_rounded,
                title: 'Profil Toko',
                subtitle: 'Ubah nama toko, alamat, & logo',
                onTap: () {},
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSettingTile(
                icon: Icons.sync_rounded,
                title: 'Sinkronisasi Cloud',
                subtitle: 'Terhubung dengan Supabase Realtime',
                trailing: Switch(
                  value: _autoSyncEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _autoSyncEnabled = val;
                    });
                  },
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Preferences Section
            _buildSectionHeader('Preferensi & Notifikasi'),
            _buildSettingCard([
              _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                title: 'Peringatan Stok Menipis',
                subtitle: 'Notifikasi saat stok di bawah batas min',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSettingTile(
                icon: Icons.cloud_download_outlined,
                title: 'Cadangkan Data (Backup)',
                subtitle: 'Ekspor database inventaris toko',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Simulasi backup data inventaris'),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            // About & Help Section
            _buildSectionHeader('Lainnya'),
            _buildSettingCard([
              _buildSettingTile(
                icon: Icons.info_outline_rounded,
                title: 'Tentang Aplikasi',
                subtitle: 'Stok Saya Inventory App v1.0.0',
                onTap: () {},
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSettingTile(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan & Dukungan',
                subtitle: 'FAQ dan pusat bantuan',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 28),

            // Logout Button
            OutlinedButton.icon(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.stockOut,
                side: const BorderSide(color: AppColors.stockOut),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Keluar dari Akun'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
    );
  }
}
