import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/smooth_page_route.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../screens/main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      SmoothPageRoute(page: const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Buat Akun Stok Saya',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lengkapi data di bawah ini untuk mulai mencatat dan mengelola stok.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              AppCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Nama Lengkap',
                      hintText: 'Masukkan nama Anda',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted, size: 20),
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Alamat Email',
                      hintText: 'nama@domain.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20),
                    ),
                    const SizedBox(height: 16),

                    AppTextField.password(
                      label: 'Kata Sandi',
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),

                    AppTextField.password(
                      label: 'Konfirmasi Kata Sandi',
                      hintText: 'Ulangi kata sandi',
                      controller: _confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleRegister(),
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Daftar Sekarang',
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
