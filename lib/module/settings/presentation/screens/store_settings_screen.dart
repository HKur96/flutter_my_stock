import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/core/widgets/app_shimmer.dart';
import 'package:provider/provider.dart';
import '../provider/store_settings_provider.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _noteController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final provider = context.read<StoreSettingsProvider>();
    await provider.fetchStoreSettings(isRefresh: true);
    if (mounted && provider.settings != null) {
      final s = provider.settings!;
      _nameController.text = s.storeName;
      _phoneController.text = s.phoneNumber ?? '';
      _addressController.text = s.address ?? '';
      _noteController.text = s.headerFooterNote ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<StoreSettingsProvider>();
    final success = await provider.updateStoreSettings(
      storeName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      headerFooterNote: _noteController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan toko berhasil disimpan'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan pengaturan toko'),
            backgroundColor: AppColors.stockOut,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Toko'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<StoreSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingShimmer();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Fields
                  _buildLabel('Nama Toko / Warung', isRequired: true),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Toko Sembako Berkah',
                      prefixIcon: Icon(Icons.store_outlined, size: 20),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    textCapitalization: TextCapitalization.words,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama toko wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildLabel('No. Telepon / WhatsApp'),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 08123456789',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 16),

                  _buildLabel('Alamat Lengkap Toko'),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.words,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Jl. Merdeka No. 45, Jakarta Selatan',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 36),
                        child: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildLabel('Catatan / Footer Nota Struk'),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(
                      hintText:
                          'Contoh: Terima kasih telah berbelanja! Barang yang sudah dibeli tidak dapat ditukar.',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Icon(Icons.notes_outlined, size: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: provider.isSaving ? null : _saveSettings,
                    child: provider.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Simpan Pengaturan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.stockOut,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer.rectangle(
            width: double.infinity,
            height: 90,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 24),
          AppShimmer.rectangle(
            width: 140,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          AppShimmer.rectangle(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          AppShimmer.rectangle(
            width: 160,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          AppShimmer.rectangle(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          AppShimmer.rectangle(
            width: 120,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          AppShimmer.rectangle(
            width: double.infinity,
            height: 80,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}
