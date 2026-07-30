import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;
  final String currentUserRole;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.currentUserRole,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ItemModel _currentItem;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return 'http://10.0.2.2:8000/storage/$path';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFDC2626);
      case 'active':
        return const Color(0xFF005BC0);
      case 'resolved':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  // Helper untuk mendapatkan ikon status yang selaras dengan Filter Status di HomeScreen
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'active':
        return Icons.run_circle_outlined;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _changeStatus() async {
    final String? selectedStatus = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Status Laporan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pilih status terbaru untuk laporan barang ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusCard(
              context,
              value: 'pending',
              label: 'Pending',
              description: 'Barang baru dilaporkan dan sedang dalam tinjauan.',
              color: const Color(0xFFDC2626),
              icon: Icons.hourglass_top_rounded,
              currentStatus: _currentItem.status,
            ),
            const SizedBox(height: 10),
            _buildStatusCard(
              context,
              value: 'active',
              label: 'Active',
              description: 'Laporan aktif dan barang sedang diproses/dicari.',
              color: const Color(0xFF005BC0),
              icon: Icons.run_circle_outlined,
              currentStatus: _currentItem.status,
            ),
            const SizedBox(height: 10),
            _buildStatusCard(
              context,
              value: 'resolved',
              label: 'Resolved',
              description: 'Barang sudah ditemukan atau diserahkan ke pemilik.',
              color: const Color(0xFF16A34A),
              icon: Icons.check_circle_outline_rounded,
              currentStatus: _currentItem.status,
            ),
          ],
        ),
      ),
    );

    if (selectedStatus != null && selectedStatus != _currentItem.status) {
      setState(() {
        _isRefreshing = true;
      });

      final res = await ApiService.updateItemStatus(_currentItem.id, selectedStatus);

      if (res['success'] == true && mounted) {
        await Future.delayed(const Duration(milliseconds: 400));

        setState(() {
          _currentItem = ItemModel(
            id: _currentItem.id,
            title: _currentItem.title,
            description: _currentItem.description,
            category: _currentItem.category,
            location: _currentItem.location,
            image: _currentItem.image,
            status: selectedStatus,
            userName: _currentItem.userName,
          );
          _isRefreshing = false;
        });
      } else if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String value,
    required String label,
    required String description,
    required Color color,
    required IconData icon,
    required String currentStatus,
  }) {
    final bool isSelected = currentStatus.toLowerCase() == value.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.06) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: color, size: 22)
              else
                const Icon(Icons.circle_outlined, color: Color(0xFFD1D5DB), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.currentUserRole.toLowerCase() == 'admin';
    final bool hasImage = _currentItem.image != null && _currentItem.image!.isNotEmpty;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrDesktop = screenWidth >= 600;

    final double heroHeight = isTabletOrDesktop ? 360 : 260;
    final bool isLost = _currentItem.category.toLowerCase() == 'lost';
    final Color statusColor = _getStatusColor(_currentItem.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF414754)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text(
          isAdmin ? 'LostFinder (Admin)' : 'LostFinder',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF005BC0),
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Image Area
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Stack(
                        children: [
                          Container(
                            height: heroHeight,
                            width: double.infinity,
                            margin: isTabletOrDesktop
                                ? const EdgeInsets.symmetric(horizontal: 16)
                                : EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEEEF),
                              borderRadius: isTabletOrDesktop
                                  ? BorderRadius.circular(16)
                                  : BorderRadius.zero,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: hasImage
                                ? Image.network(
                                    _getImageUrl(_currentItem.image!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 48, color: Color(0xFF727785)),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.inventory_2_outlined,
                                        size: 64, color: Color(0xFF727785)),
                                  ),
                          ),

                          // Badges Kategori & Status di Atas Gambar
                          Positioned(
                            top: 16,
                            right: isTabletOrDesktop ? 32 : 16,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isLost
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isLost
                                            ? Icons.search_rounded
                                            : Icons.check_circle_outline_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _currentItem.category.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: isAdmin ? _changeStatus : null,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(_currentItem.status),
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _currentItem.status.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.edit_outlined,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ],
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

                  // Detail Body
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTabletOrDesktop ? 32 : 16,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMainDetailCard(isLost, statusColor, isAdmin),
                            const SizedBox(height: 20),
                            _buildActionCard(isTabletOrDesktop),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isRefreshing)
            Container(
              color: Colors.white.withOpacity(0.65),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF005BC0),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Memperbarui laporan...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF005BC0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainDetailCard(bool isLost, Color statusColor, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentItem.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191C1D),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (_currentItem.description != null && _currentItem.description!.isNotEmpty)
                ? _currentItem.description!
                : 'Tidak ada deskripsi tambahan.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF414754),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.location_on,
            text: _currentItem.location,
          ),
          const SizedBox(height: 12),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _currentItem.userId != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          currentUserRole: _currentItem.userRole ?? 'User',
                          currentUserId: _currentItem.userId!,
                          isCurrentUser: false,
                        ),
                      ),
                    );
                  }
                : null,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE5E7EB),
                  backgroundImage: _currentItem.userPhoto != null && _currentItem.userPhoto!.isNotEmpty
                      ? NetworkImage(ApiService.resolvePhotoUrl(_currentItem.userPhoto!))
                      : null,
                  child: _currentItem.userPhoto == null || _currentItem.userPhoto!.isEmpty
                      ? Text(
                          _currentItem.userName.isNotEmpty ? _currentItem.userName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: Color(0xFF005BC0),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentItem.userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                      if (_currentItem.userEmail != null && _currentItem.userEmail!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _currentItem.userEmail!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // AREA TAGS DENGAN IKON LENGKAP & SELARAS
          _buildInfoRow(
            icon: Icons.sell_outlined,
            customWidget: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Tag Kategori (Lost / Found)
                _buildTag(
                  _currentItem.category.toUpperCase(),
                  bgColor: isLost
                      ? const Color(0xFFDC2626).withOpacity(0.12)
                      : const Color(0xFF16A34A).withOpacity(0.12),
                  textColor: isLost ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  icon: isLost
                      ? Icons.search_rounded
                      : Icons.check_circle_outline_rounded,
                ),

                // Tag Status (Pending / Active / Resolved)
                GestureDetector(
                  onTap: isAdmin ? _changeStatus : null,
                  child: _buildTag(
                    'STATUS: ${_currentItem.status.toUpperCase()}',
                    bgColor: statusColor.withOpacity(0.12),
                    textColor: statusColor,
                    icon: _getStatusIcon(_currentItem.status),
                    trailingIcon: isAdmin ? Icons.edit : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isWideScreen
          ? Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apakah ini barang milik Anda?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Verifikasi kepemilikan untuk mengatur pengambilan dengan Petugas.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF414754),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _showContactOptions,
                  icon: const Icon(Icons.handshake_outlined, size: 20),
                  label: const Text('Ini Milik Saya'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const Text(
                  'Apakah ini barang milik Anda?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verifikasi kepemilikan untuk mengatur pengambilan dengan Petugas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF414754),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showContactOptions,
                    icon: const Icon(Icons.handshake_outlined, size: 20),
                    label: const Text(
                      'Ini Milik Saya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showContactOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Hubungi Admin atau Pelapor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih salah satu untuk mendapatkan bantuan atau mengonfirmasi kepemilikan.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1A73E8),
                child: Icon(Icons.support_agent, color: Colors.white),
              ),
              title: const Text('Hubungi Admin'),
              subtitle: const Text('Dapatkan bantuan dari tim LostFinder'),
              onTap: () {
                Navigator.pop(context);
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hubungi Admin'),
                    content: const Text('Silakan hubungi admin untuk menyelesaikan verifikasi barang ini.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF005BC0),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Hubungi Pelapor'),
              subtitle: const Text('Konfirmasi langsung dengan pelapor barang'),
              onTap: () {
                Navigator.pop(context);
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hubungi Pelapor'),
                    content: const Text('Silakan hubungi pelapor untuk mengonfirmasi apakah barang ini milik Anda.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    String? text,
    Widget? customWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF414754)),
        const SizedBox(width: 10),
        if (text != null)
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF414754),
              ),
            ),
          ),
        if (customWidget != null) customWidget,
      ],
    );
  }

  // Helper Widget Tag yang Mendukung Ikon Depan dan Belakang (Edit)
  Widget _buildTag(
    String label, {
    required Color bgColor,
    required Color textColor,
    IconData? icon,
    IconData? trailingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 5),
            Icon(trailingIcon, size: 12, color: textColor),
          ],
        ],
      ),
    );
  }
}