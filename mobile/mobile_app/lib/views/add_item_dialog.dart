import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddItemDialog extends StatefulWidget {
  final int currentUserId;
  final VoidCallback onSuccess;

  const AddItemDialog({
    super.key,
    required this.currentUserId,
    required this.onSuccess,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Default category diubah ke 'lost' sesuai kriteria status laporan
  String _category = 'lost';
  XFile? _pickedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Warna sesuai Palette Tailwind HTML
  static const Color primaryColor = Color(0xFF005BBF);
  static const Color surfaceBg = Color(0xFFF8F9FA);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xFF191C1D);
  static const Color textMuted = Color(0xFF414754);
  static const Color borderOutline = Color(0xFFC1C6D6);
  static const Color errorColor = Color(0xFFBA1A1A);

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_titleController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama barang & lokasi wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.addItemWithImage(
        userId: widget.currentUserId,
        title: _titleController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        imageFile: _pickedImage,
      );

      if (res['success'] == true && mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        _showSuccessDialog();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Gagal menyimpan.'),
              backgroundColor: errorColor,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }
  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFEFF7EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFDCF7E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 56,
                color: Color(0xFF0F8D3A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Laporan Tersimpan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F8D3A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Terima kasih. Laporan Anda sudah masuk dan menunggu verifikasi admin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F8D3A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Helper Decoration Input Input Campus Style
  InputDecoration _inputStyle({required String hintText, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF727785), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF727785)) : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: surfaceBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Scaffold(
          backgroundColor: surfaceBg,
          appBar: AppBar(
            backgroundColor: surfaceBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: textMain),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Report Item',
              style: TextStyle(
                color: textMain,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title & Subtitle
                const Text(
                  'Report Lost / Found Item',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Provide details to help the campus community find or return the item.',
                  style: TextStyle(fontSize: 14, color: textMuted),
                ),
                const SizedBox(height: 20),

                // SECTION 1: Item Details (Bento Card 1)
                _buildBentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(Icons.info_outline_rounded, 'Item Details'),
                      const SizedBox(height: 16),
                      _buildLabel('Item Name', isRequired: true),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: textMain, fontSize: 14),
                        decoration: _inputStyle(hintText: 'e.g., Blue HydroFlask, MacBook Pro'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Dropdown Kategori / Status Laporan
                      _buildLabel('Category / Status', isRequired: true),
                      DropdownButtonFormField<String>(
                        value: _category,
                        style: const TextStyle(color: textMain, fontSize: 14),
                        icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF727785)),
                        decoration: _inputStyle(hintText: 'Select category status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'lost', 
                            child: Text('Barang Hilang (Lost)'),
                          ),
                          DropdownMenuItem(
                            value: 'found', 
                            child: Text('Barang Ditemukan (Found)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION 2: When & Where (Bento Card 2)
                _buildBentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(Icons.pin_drop_outlined, 'When & Where'),
                      const SizedBox(height: 16),
                      _buildLabel('Last Seen / Found Location', isRequired: true),
                      TextField(
                        controller: _locationController,
                        style: const TextStyle(color: textMain, fontSize: 14),
                        decoration: _inputStyle(
                          hintText: 'e.g., Library 2nd Floor, Main Quad',
                          suffixIcon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION 3: Visuals & Description (Bento Card 3)
                _buildBentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(Icons.image_outlined, 'Visuals & Description'),
                      const SizedBox(height: 16),
                      _buildLabel('Upload Image (Optional)', isRequired: false),
                      
                      // Custom Upload Container
                      InkWell(
                        onTap: _isLoading
                            ? null
                            : () async {
                                final XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
                                );
                                if (image != null) {
                                  setState(() => _pickedImage = image);
                                }
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _pickedImage == null ? borderOutline : primaryColor,
                              style: BorderStyle.solid, 
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_pickedImage == null) ...[
                                const Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF727785)),
                                const SizedBox(height: 8),
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(fontSize: 14, color: textMuted),
                                    children: [
                                      TextSpan(
                                        text: 'Upload a file ',
                                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                                      ),
                                      TextSpan(text: 'from gallery'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'PNG, JPG, GIF up to 10MB',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF727785)),
                                ),
                              ] else ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(_pickedImage!.path, height: 120, fit: BoxFit.cover)
                                      : Image.file(File(_pickedImage!.path), height: 120, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check_circle, size: 18, color: Color(0xFF006D2C)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Foto berhasil dipilih',
                                      style: TextStyle(color: Color(0xFF006D2C), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                )
                              ]
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Description', isRequired: false),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(color: textMain, fontSize: 14),
                        decoration: _inputStyle(hintText: 'Distinctive features, colors, brands, or contents...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ACTION BUTTONS
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Submit Report',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper Card Bento Style
  Widget _buildBentoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Widget Helper Header Card Section
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
      ],
    );
  }

  // Widget Helper Label dengan tanda Bintang (*) Merah
  Widget _buildLabel(String labelText, {required bool isRequired}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: errorColor, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}