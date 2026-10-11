import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
import 'package:flutter_catat_stok/core/widgets/app_shimmer.dart';
import 'package:provider/provider.dart';
import '../provider/unit_provider.dart';
import '../../domain/models/unit_item.dart';

class ManageUnitScreen extends StatefulWidget {
  const ManageUnitScreen({super.key});

  @override
  State<ManageUnitScreen> createState() => _ManageUnitScreenState();
}

class _ManageUnitScreenState extends State<ManageUnitScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnitProvider>().fetchUnits();
    });
  }

  void _showAddUnitModal() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
          child: Form(
            key: formKey,
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
                const Text(
                  'Tambah Satuan Baru',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nama Satuan *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Bal, Karton, Slop, Botol, Sachet',
                    prefixIcon: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama satuan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Keterangan (Opsional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Isi 10 pack kecil',
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = context.read<UnitProvider>();
                      final success = await provider.addUnit(
                        name: nameController.text.trim(),
                        description: descController.text.trim().isNotEmpty
                            ? descController.text.trim()
                            : null,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Satuan berhasil ditambahkan'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Tambah Satuan'),
                ),
              ],
            ),
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
        title: const Text('Satuan Barang Dagangan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manage_unit_fab',
        onPressed: _showAddUnitModal,
        backgroundColor: AppColors.primary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Satuan Baru',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<UnitProvider>().fetchUnits(),
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
                        Icons.inventory_2_rounded,
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
                            'Satuan Kuantitas Produk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kelola jenis satuan hitung (Pcs, Box, Dus, Bal, Karton, dll) sesuai barang dagangan Anda.',
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

              // List of Units
              Consumer<UnitProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return _buildLoadingShimmer();
                  }

                  final units = provider.units;
                  if (units.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.all(24),
                      child: const Center(
                        child: Text(
                          'Belum ada satuan. Klik + Satuan Baru untuk menambah.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: units.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = units[index];
                      return _buildUnitCard(item);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitCard(UnitItem item) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.stockOut,
              size: 18,
            ),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceCard,
                  title: const Text('Hapus Satuan?'),
                  content: Text('Apakah Anda yakin ingin menghapus satuan "${item.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.stockOut,
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                context.read<UnitProvider>().deleteUnit(item.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppShimmer.rectangle(
            width: double.infinity,
            height: 60,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
