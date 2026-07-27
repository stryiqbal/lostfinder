import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // State untuk menyimpan pesan error di dalam form
  String? _errorMessage;

  // Palet Warna disesuaikan dengan Tailwind Config di HTML
  static const Color primaryColor = Color(0xFF005BBF);
  static const Color primaryContainer = Color(0xFF1A73E8);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceCardColor = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF414754);
  static const Color outlineVariant = Color(0xFFC1C6D6);
  static const Color primaryFixedLight = Color(0x33D8E2FF); // primary-fixed/20

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset error message setiap kali tombol ditekan
    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan Password tidak boleh kosong!';
      });
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.login(email, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final userData = result['data'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat Datang, ${userData['name']}!'),
          backgroundColor: const Color(0xFF006D2C),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreenWithRole(
            currentUserRole: userData['role'],
            currentUserId: userData['id'],
          ),
        ),
      );
    } else {
      // Tampilkan error dari server langsung di dalam form
      setState(() {
        _errorMessage = result['message'] ?? 'Login Gagal. Silakan coba lagi.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth >= 768;

          return Row(
            children: [
              // Sisi Gambar Kiri (Desktop Mode)
              if (isDesktop)
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBX2yypLeOmrDTjfUzeft9mlJIvO2W7DIS4UO0wKtnc8jdX_ZaQQ4PDgGD-1eNmwK-Ou5fimyAi75zvVe4jqw3Lp4exEAjzVcEIwl4VWrZp_DKsGzwjmb2PeVMaQ-oWQS6AefaqfaJKgz2oCisgXSH2uRGDH5fbCYT80ix3wXqLK-eTpnS6nPh-W0W-V_lkr3dhNo4Ccc88Iwd_zrRtUlf_tYAPzH-vfbPemZ9PQdbj_WMt0BfFnzppi8Woo-q6JjyPZQ9AY6d5PcI',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFFF3F4F5).withOpacity(0.2),
                              backgroundColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Recover what matters.',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: onSurfaceColor,
                                height: 1.25,
                                letterSpacing: -0.64,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your trusted campus utility for reporting and finding lost items quickly and efficiently.',
                              style: TextStyle(
                                fontSize: 16,
                                color: onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Sisi Form Login (Mobile & Right Side Desktop)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: surfaceCardColor,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: outlineVariant.withOpacity(0.3),
                          ),
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
                            // Header Brand & Icon
                            Center(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: primaryContainer,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Icon(
                                  Icons.saved_search_rounded,
                                  size: 28,
                                  color: onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'LostFinder',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: -0.64,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome Back',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: onSurfaceColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Enter your account to continue.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // --- BANNER ALERT ERROR IN-FORM ---
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFDAD6), // Red container light
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFBA1A1A).withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Color(0xFFBA1A1A),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFBA1A1A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Field Campus Email
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: onSurfaceVariant,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontSize: 16,
                                color: onSurfaceColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'student@gmail.com',
                                hintStyle: TextStyle(
                                  color: outlineVariant.withOpacity(0.8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                filled: true,
                                fillColor: surfaceCardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field Password
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: onSurfaceVariant,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleLogin(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: onSurfaceColor,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(
                                  color: outlineVariant.withOpacity(0.8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                filled: true,
                                fillColor: surfaceCardColor,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: outlineVariant,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(top: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Button Login
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
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
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider & Navigasi Registrasi
                            Container(
                              padding: const EdgeInsets.only(top: 24.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFFE1E3E4), // surface-variant
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(9999),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryFixedLight,
                                        borderRadius:
                                            BorderRadius.circular(9999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Register a new account',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: primaryColor,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 16,
                                            color: primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}