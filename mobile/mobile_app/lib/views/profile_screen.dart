import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserRole;
  final int currentUserId;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    required this.currentUserRole,
    required this.currentUserId,
    this.isCurrentUser = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _bio = '';
  String _role = '';
  String? _photoUrl; // Penampung URL foto dari backend

  // Palette Warna Material 3
  static const Color primaryColor = Color(0xFF005BBF);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE1E3E4);
  static const Color textPrimary = Color(0xFF191C1D);
  static const Color textSecondary = Color(0xFF414754);
  static const Color textOutline = Color(0xFF727785);
  static const Color borderVariant = Color(0xFFC1C6D6);
  static const Color errorColor = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final isAdmin = widget.currentUserRole.toLowerCase() == 'admin';

    try {
      final userData = await ApiService.getUserProfile(widget.currentUserId);
      if (userData != null && mounted) {
        
        final rawPhoto = userData['photo_url'] ?? userData['photo'];
        final resolvedPhotoUrl = ApiService.resolvePhotoUrl(rawPhoto?.toString());
        final profileRole = userData['role']?.toString() ?? widget.currentUserRole;

        setState(() {
          _name = userData['name'] ?? (isAdmin ? 'Admin LostFinder' : 'Budi Santoso');
          _email = userData['email'] ?? (isAdmin ? 'admin@campus.edu' : 'b.santoso@campus.edu');
          _phone = userData['phone'] ?? '+62 812 3456 7890';
          _bio = userData['bio'] ?? 'Computer Science student. If you find my things, please contact me!';
          _photoUrl = resolvedPhotoUrl.isNotEmpty ? resolvedPhotoUrl : null;
          _role = profileRole;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    if (mounted) {
      setState(() {
        _name = isAdmin ? 'Admin LostFinder' : 'Budi Santoso';
        _email = isAdmin ? 'admin@campus.edu' : 'b.santoso@campus.edu';
        _phone = '+62 812 3456 7890';
        _bio = 'Computer Science student. If you find my things, please contact me!';
        _photoUrl = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentUserId: widget.currentUserId,
          initialName: _name,
          initialEmail: _email,
          initialPhone: _phone,
          initialBio: _bio,
          initialPhotoUrl: _photoUrl,
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadUserData(); // Re-fetch data profil terbaru setelah save
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFDAD6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 32,
                color: errorColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keluar dari Aplikasi?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sesi Anda akan diakhiri. Sesi berikutnya memerlukan login ulang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: textOutline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textSecondary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.isCurrentUser ? 'Profil Saya' : 'Profil Pengguna',
          style: const TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: widget.isCurrentUser
            ? [
                TextButton(
                  onPressed: _navigateToEditProfile,
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header Profil & Foto
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 24),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 64,
                                backgroundColor: surfaceVariant,
                                backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                                    ? NetworkImage(_photoUrl!)
                                    : null,
                                child: _photoUrl == null || _photoUrl!.isEmpty
                                    ? Text(
                                        _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _role.isNotEmpty ? _role.toUpperCase() : widget.currentUserRole.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Kartu Informasi Akun
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderVariant),
                          ),
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.person_outline,
                                label: 'Full Name',
                                value: _name,
                              ),
                              const Divider(height: 24, color: surfaceVariant),
                              _buildInfoTile(
                                icon: Icons.badge_outlined,
                                label: 'Campus ID',
                                value: widget.currentUserId.toString(),
                              ),
                              const Divider(height: 24, color: surfaceVariant),
                              _buildInfoTile(
                                icon: Icons.email_outlined,
                                label: 'University Email',
                                value: _email,
                              ),
                              const Divider(height: 24, color: surfaceVariant),
                              _buildInfoTile(
                                icon: Icons.phone_outlined,
                                label: 'Phone Number',
                                value: _phone,
                              ),
                              const Divider(height: 24, color: surfaceVariant),
                              _buildInfoTile(
                                icon: Icons.info_outline,
                                label: 'Bio / Description',
                                value: _bio,
                              ),
                            ],
                          ),
                        ),

                        if (widget.isCurrentUser) ...[
                          const SizedBox(height: 24),
                          // Tombol Keluar Akun
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _handleLogout,
                              icon: const Icon(Icons.logout_rounded, size: 20, color: errorColor),
                              label: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: errorColor,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: surfaceLowest,
                                side: const BorderSide(color: Color(0xFFFFDAD6)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}