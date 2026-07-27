import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Palet Warna UI
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE1E3E4);
  static const Color primaryContainer = Color(0xFF1A73E8);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF414754);
  static const Color outlineVariant = Color(0xFFC1C6D6);
  static const Color outlineColor = Color(0xFF727785);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFFBA1A1A);

  void _handleUpdatePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() => _errorMessage = null);

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Semua bidang wajib diisi!');
      return;
    }

    if (newPassword.length < 6) {
      setState(() => _errorMessage = 'Password baru minimal 6 karakter!');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Konfirmasi password baru tidak cocok!');
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.resetPassword(
      email: widget.email,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      // Show Custom Modern Success Dialog
      _showSuccessDialog(response['message'] ?? 'Password berhasil diperbarui, silakan login kembali!');
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'Gagal memperbarui password.';
      });
    }
  }

  // --- CUSTOM ALERT DIALOG (BERHASIL) ---
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), // M3 Dialog Radius
        ),
        backgroundColor: surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header Sukses
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryContainer.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: primaryContainer,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),

              // Content / Subtitle
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: onSurfaceVariant,
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryContainer,
                    foregroundColor: onPrimaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: const BoxDecoration(
                color: backgroundColor,
                border: Border(
                  bottom: BorderSide(color: surfaceVariant, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: onSurface),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Atur Ulang Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Silakan masukkan password lama Anda dan buat password baru untuk memperbarui kredensial akun LostFinder Anda.',
                          style: TextStyle(
                            fontSize: 14,
                            color: onSurfaceVariant,
                            height: 1.42,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Alert Error (Jika Ada)
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: errorContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: onErrorContainer.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: onErrorContainer,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: onErrorContainer,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => _errorMessage = null),
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.close,
                                      color: onErrorContainer,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Form Inputs
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPasswordField(
                              label: 'Password Lama',
                              hintText: 'Masukkan password lama',
                              controller: _oldPasswordController,
                              obscureText: _obscureOld,
                              onToggleVisibility: () {
                                setState(() => _obscureOld = !_obscureOld);
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildPasswordField(
                              label: 'Password Baru',
                              hintText: 'Buat password baru',
                              controller: _newPasswordController,
                              obscureText: _obscureNew,
                              onToggleVisibility: () {
                                setState(() => _obscureNew = !_obscureNew);
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildPasswordField(
                              label: 'Konfirmasi Password Baru',
                              hintText: 'Ketik ulang password baru',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              onToggleVisibility: () {
                                setState(() => _obscureConfirm = !_obscureConfirm);
                              },
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleUpdatePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryContainer,
                                  foregroundColor: onPrimaryContainer,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
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
                                        'Simpan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: onSurface,
            letterSpacing: 0.6,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 14,
            color: onSurface,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: outlineColor,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: surfaceContainerLowest,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: outlineColor,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
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
                color: primaryContainer,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}