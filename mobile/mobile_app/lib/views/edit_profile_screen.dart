import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final int currentUserId;
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialBio;
  final String? initialPhotoUrl;

  const EditProfileScreen({
    super.key,
    required this.currentUserId,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialBio,
    this.initialPhotoUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _campusIdController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  bool _isSaving = false;
  String? _photoUrl;

  // Variabel untuk Image Picker & Penampung Foto
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  // Material 3 Color Palette
  static const Color primaryColor = Color(0xFF005BBF);
  static const Color primaryContainer = Color(0xFF1A73E8);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
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
    _campusIdController = TextEditingController(text: widget.currentUserId.toString());
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _bioController = TextEditingController(text: widget.initialBio);
    _photoUrl = widget.initialPhotoUrl;
  }

  @override
  void dispose() {
    _campusIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih foto dari Galeri
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres ukuran gambar
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Mengirimkan parameter photoFile ke ApiService
      final Map<String, dynamic> response = await ApiService.updateProfile(
        userId: widget.currentUserId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        photoFile: _selectedImage, // Berkas foto dikirimkan di sini
      );

      if (!mounted) return;

      final bool isSuccess = response['success'] == true ||
          response['status'] == true ||
          response['status'] == 'success';

      if (isSuccess) {
        await _showProfileUpdatedDialog();
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final String errorMessage = response['message'] ?? 'Gagal memperbarui profil. Silakan coba lagi.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showProfileUpdatedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: primaryContainer.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: primaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profil Berhasil Diperbarui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Perubahan profil Anda berhasil disimpan. Terima kasih telah memperbarui informasi Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryContainer,
                    foregroundColor: onPrimaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture Section
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // Jika user memilih gambar baru, tampilkan preview gambar dari byte memory
                              if (_selectedImage != null)
                                FutureBuilder<Uint8List>(
                                  future: _selectedImage!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return CircleAvatar(
                                        radius: 64,
                                        backgroundColor: surfaceVariant,
                                        backgroundImage: MemoryImage(snapshot.data!),
                                      );
                                    }
                                    return const CircleAvatar(
                                      radius: 64,
                                      backgroundColor: surfaceVariant,
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                )
                              else if (_photoUrl != null && _photoUrl!.isNotEmpty)
                                CircleAvatar(
                                  radius: 64,
                                  backgroundColor: surfaceVariant,
                                  backgroundImage: NetworkImage(_photoUrl!),
                                )
                              else
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _nameController,
                                  builder: (context, value, child) {
                                    final initial = value.text.trim().isNotEmpty
                                        ? value.text.trim()[0].toUpperCase()
                                        : 'U';
                                    return CircleAvatar(
                                      radius: 64,
                                      backgroundColor: surfaceVariant,
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,

                                        ),
                                      ),
                                    );
                                  },
                                ),
                              Material(
                                color: primaryContainer,
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _pickImage, // Memanggil fungsi pemilih foto
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: surfaceColor, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.photo_camera,
                                      size: 20,
                                      color: onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap camera icon to change photo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Fields List
                    Column(
                      children: [
                        // Full Name
                        _buildInputField(
                          label: 'Full Name',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full Name tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Campus ID (Disabled/Read-only)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Campus ID',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondary,
                                  ),
                                ),
                                Icon(
                                  Icons.lock_outline,
                                  size: 16,
                                  color: borderVariant,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _campusIdController,
                              enabled: false,
                              style: TextStyle(
                                fontSize: 16,
                                color: textSecondary.withOpacity(0.7),
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                filled: true,
                                fillColor: surfaceVariant,
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: borderVariant),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Campus ID cannot be changed directly.',
                              style: TextStyle(
                                fontSize: 12,
                                color: textOutline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // University Email
                        _buildInputField(
                          label: 'University Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!value.contains('@')) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        _buildInputField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Bio / Description
                        _buildInputField(
                          label: 'Bio / Description',
                          controller: _bioController,
                          maxLines: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 16,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: surfaceLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: errorColor),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}