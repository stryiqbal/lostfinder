import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Palet Warna UI (Sesuai Konfigurasi Tailwind M3)
  static const Color primaryColor = Color(0xFF005BBF);
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color primaryContainer = Color(0xFF1A73E8);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceCardColor = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF414754);
  static const Color outlineVariant = Color(0xFFC1C6D6);
  static const Color outlineColor = Color(0xFF727785);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFFBA1A1A);

  void _handleResetPassword() async {
    final email = _emailController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Email tidak boleh kosong!');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Format email tidak valid!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.forgotPassword(email);

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() => _isLoading = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['message'] ?? 'Email tidak terdaftar!';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan jaringan/koneksi backend.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448), // max-w-md
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Card Kontainer Utama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32.0), // p-xl
                    decoration: BoxDecoration(
                      color: surfaceCardColor,
                      borderRadius: BorderRadius.circular(12.0), // rounded-xl
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Icon Header Circle
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: primaryFixed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 40,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title Header
                        const Text(
                          'Lupa Password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24, // headline-lg
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                            letterSpacing: -0.24,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Masukkan email Anda yang terdaftar untuk memverifikasi akun.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, // body-lg
                              color: onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Alert Pesan Error
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: errorContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: onErrorContainer.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Form input Email Universitas
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 12, // label-md
                                fontWeight: FontWeight.w500,
                                color: onSurface,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleResetPassword(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'student@gmail.com',
                                hintStyle: const TextStyle(
                                  color: outlineColor,
                                  fontSize: 16,
                                ),
                                prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  color: outlineColor,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                filled: true,
                                fillColor: surfaceCardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleResetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryContainer,
                              foregroundColor: onPrimaryContainer,
                              elevation: 0,
                              shadowColor: Colors.black.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999), // full radius
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: onPrimaryContainer,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 18, // title-md
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Secondary Link (Kembali ke Masuk)
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Kembali ke Login',
                                    style: TextStyle(
                                      fontSize: 14, // body-md
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,

                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Absolute Back Button (Pojok Kiri Atas Card)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9999),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}