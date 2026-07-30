import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'item_detail_screen.dart';
import 'add_item_dialog.dart';
import 'profile_screen.dart';

class HomeScreenWithRole extends StatefulWidget {
  final String currentUserRole;
  final int currentUserId;

  const HomeScreenWithRole({
    super.key,
    required this.currentUserRole,
    required this.currentUserId,
  });

  @override
  State<HomeScreenWithRole> createState() => _HomeScreenWithRoleState();
}

class _HomeScreenWithRoleState extends State<HomeScreenWithRole> {
  late Future<List<ItemModel>> futureItems;
  List<ItemModel> _allItems = [];
  List<ItemModel> _filteredItems = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String _selectedCategory = 'All Items';
  String _selectedStatus = 'All Status';
  int _currentBottomNavIndex = 0;

  // KATEGORI (LOST / FOUND / ALL)
  final List<Map<String, dynamic>> _categories = [
    {'label': 'All Items', 'icon': null},
    {'label': 'Lost', 'icon': Icons.search_rounded},
    {'label': 'Found', 'icon': Icons.check_circle_outline_rounded},
  ];

  // STATUS (PENDING / ACTIVE / RESOLVED / ALL)
  final List<Map<String, dynamic>> _statusFilters = [
    {'label': 'All Status', 'icon': null},
    {'label': 'Pending', 'icon': Icons.hourglass_top_rounded},
    {'label': 'Active', 'icon': Icons.run_circle_outlined},
    {'label': 'Resolved', 'icon': Icons.check_circle_outline_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _refreshItems() {
    setState(() {
      futureItems = ApiService.getItems().then((items) {
        _allItems = items;
        _applyFilters();
        return items;
      });
    });
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = _allItems.where((item) {
        final matchesSearch = item.title.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query);

        final matchesCategory = _selectedCategory == 'All Items' ||
            (item.category.toLowerCase() == _selectedCategory.toLowerCase());

        final matchesStatus = _selectedStatus == 'All Status' ||
            (item.status.toLowerCase() == _selectedStatus.toLowerCase());

        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
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

  // HELPER IKON STATUS UNTUK KESELARASAN SELURUH HALAMAN
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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Baru';
    }

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = monthNames[date.month - 1];
    final year = date.year.toString();

    return '$day $month $year';
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddItemDialog(
        currentUserId: widget.currentUserId,
        onSuccess: _refreshItems,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final bool confirm = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEDEA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 32,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keluar dari Aplikasi?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sesi Anda akan diakhiri. Sesi berikutnya memerlukan login ulang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (confirm && mounted) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _changeStatus(ItemModel item) async {
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
              currentStatus: item.status,
            ),
            const SizedBox(height: 10),
            _buildStatusCard(
              context,
              value: 'active',
              label: 'Active',
              description: 'Laporan aktif dan barang sedang diproses/dicari.',
              color: const Color(0xFF005BC0),
              icon: Icons.run_circle_outlined,
              currentStatus: item.status,
            ),
            const SizedBox(height: 10),
            _buildStatusCard(
              context,
              value: 'resolved',
              label: 'Resolved',
              description: 'Barang sudah ditemukan atau diserahkan ke pemilik.',
              color: const Color(0xFF16A34A),
              icon: Icons.check_circle_outline_rounded,
              currentStatus: item.status,
            ),
          ],
        ),
      ),
    );

    if (selectedStatus != null && selectedStatus != item.status) {
      final res = await ApiService.updateItemStatus(item.id, selectedStatus);
      if (res['success'] == true && mounted) {
        _refreshItems();
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

  Future<void> _deleteItem(ItemModel item) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEDEA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      size: 32,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hapus Laporan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apakah Anda yakin ingin menghapus laporan "${item.title}"? Tindakan ini tidak dapat dibatalkan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFFF3F4F6),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Ya, Hapus',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
        ) ??
        false;

    if (confirm) {
      final res = await ApiService.deleteItem(item.id);
      if (res['success'] == true && mounted) {
        _refreshItems();
      }
    }
  }

  Widget _buildFilterChipGroup({
    required List<Map<String, dynamic>> items,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: items.map((item) {
          final isSelected = selectedValue == item['label'];

          final contentColor = isSelected
              ? Colors.white
              : const Color(0xFF191C1D);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item['icon'] != null) ...[
                    Icon(
                      item['icon'],
                      size: 18,
                      color: contentColor,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: contentColor,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1A73E8),
              backgroundColor: const Color(0xFFEDEEEF),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (bool selected) {
                onSelected(item['label']);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUserRole == 'admin';
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    double childAspectRatio = 0.85;

    if (screenWidth > 1100) {
      crossAxisCount = 4;
      childAspectRatio = 0.95;
    } else if (screenWidth > 650) {
      crossAxisCount = 3;
      childAspectRatio = 0.90;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: RefreshIndicator(
              color: const Color(0xFF005BC0),
              onRefresh: () async => _refreshItems(),
              child: CustomScrollView(
                slivers: [
                  // TOP BAR & SEARCH AREA
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: _refreshItems,
                                icon: const Icon(Icons.refresh, color: Color(0xFF005BC0), size: 28),
                                tooltip: 'Refresh Status',
                              ),
                              Text(
                                isAdmin ? 'LostFinder (Admin)' : 'LostFinder',
                                style: const TextStyle(
                                  color: Color(0xFF005BC0),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A), size: 26),
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFD9DADB)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (_) => _applyFilters(),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF191C1D)),
                              decoration: InputDecoration(
                                hintText: 'Search for items, locations...',
                                hintStyle: const TextStyle(color: Color(0xFF727785), fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF727785)),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close, color: Color(0xFF727785), size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          _applyFilters();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // CATEGORIES & STATUS FILTERS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildFilterChipGroup(
                            items: _categories,
                            selectedValue: _selectedCategory,
                            onSelected: (value) {
                              setState(() {
                                _selectedCategory = value;
                                _applyFilters();
                              });
                            },
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildFilterChipGroup(
                            items: _statusFilters,
                            selectedValue: _selectedStatus,
                            onSelected: (value) {
                              setState(() {
                                _selectedStatus = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SECTION HEADER
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text(
                        'Daftar Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                    ),
                  ),

                  // GRID ITEMS CONTENT
                  FutureBuilder<List<ItemModel>>(
                    future: futureItems,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator(color: Color(0xFF005BC0))),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Gagal memuat data:\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF727785)),
                              ),
                            ),
                          ),
                        );
                      }

                      if (_filteredItems.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(
                              child: Text(
                                'Tidak ada barang ditemukan.',
                                style: TextStyle(color: Color(0xFF727785), fontSize: 14),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: childAspectRatio,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _filteredItems[index];
                              final hasImage = item.image != null && item.image!.isNotEmpty;
                              final isLost = item.category.toLowerCase() == 'lost';
                              final statusColor = _getStatusColor(item.status);

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF3F4F5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final isUpdated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ItemDetailScreen(
                                              item: item,
                                              currentUserRole: widget.currentUserRole,
                                            ),
                                          ),
                                        );

                                        if (isUpdated == true) {
                                          _refreshItems();
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Image Box & Badges
                                          Stack(
                                            children: [
                                              AspectRatio(
                                                aspectRatio: 16 / 10,
                                                child: Container(
                                                  color: const Color(0xFFEDEEEF),
                                                  child: hasImage
                                                      ? Image.network(
                                                          _getImageUrl(item.image!),
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) =>
                                                              const Icon(Icons.broken_image, color: Color(0xFF727785)),
                                                        )
                                                      : const Center(
                                                          child: Icon(
                                                            Icons.inventory_2_outlined,
                                                            size: 36,
                                                            color: Color(0xFF727785),
                                                          ),
                                                        ),
                                                ),
                                              ),

                                              // BADGE CATEGORY (LOST / FOUND)
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isLost
                                                        ? const Color(0xFFDC2626)
                                                        : const Color(0xFF16A34A),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
                                                        size: 10,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        item.category.toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // BADGE STATUS (DENGAN IKON LENGKAP & EDIT ICON UNTUK ADMIN)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: InkWell(
                                                  onTap: isAdmin ? () => _changeStatus(item) : null,
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: statusColor,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          _getStatusIcon(item.status),
                                                          size: 10,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(width: 3),
                                                        Text(
                                                          item.status.toUpperCase(),
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        if (isAdmin) ...[
                                                          const SizedBox(width: 3),
                                                          const Icon(
                                                            Icons.edit_outlined,
                                                            size: 9,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Delete Button (Admin)
                                              if (isAdmin)
                                                Positioned(
                                                  top: 36,
                                                  left: 8,
                                                  child: CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor: Colors.white.withOpacity(0.9),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: const Icon(Icons.delete_outline, size: 15, color: Color(0xFFBA1A1A)),
                                                      onPressed: () => _deleteItem(item),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),

                                          // Details Area
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13,
                                                          color: Color(0xFF191C1D),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.location_on, size: 12, color: Color(0xFF414754)),
                                                          const SizedBox(width: 2),
                                                          Expanded(
                                                            child: Text(
                                                              item.location,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                fontSize: 11,
                                                                color: Color(0xFF414754),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      GestureDetector(
                                                        behavior: HitTestBehavior.translucent,
                                                        onTap: item.userId != null
                                                            ? () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ProfileScreen(
                                                                      currentUserRole: item.userRole ?? 'User',
                                                                      currentUserId: item.userId!,
                                                                      isCurrentUser: item.userId == widget.currentUserId,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            : null,
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 10,
                                                              backgroundColor: const Color(0xFFE5E7EB),
                                                              backgroundImage: item.userPhoto != null && item.userPhoto!.isNotEmpty
                                                                  ? NetworkImage(ApiService.resolvePhotoUrl(item.userPhoto!))
                                                                  : null,
                                                              child: item.userPhoto == null || item.userPhoto!.isEmpty
                                                                  ? Text(
                                                                      item.userName.isNotEmpty ? item.userName[0].toUpperCase() : 'A',
                                                                      style: const TextStyle(
                                                                        color: Color(0xFF005BC0),
                                                                        fontSize: 12,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    )
                                                                  : null,
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                item.userName,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(0xFF414754),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    _formatDate(item.createdAt),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF727785),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: _filteredItems.length,
                          ),
                        ),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: BottomNavigationBar(
              currentIndex: _currentBottomNavIndex,
              onTap: (index) {
                setState(() {
                  _currentBottomNavIndex = index;
                });

                if (index == 1) {
                  _searchFocusNode.requestFocus();
                } else if (index == 2) {
                  _showAddItemDialog();
                } else if (index == 3) {
                  // Berpindah ke Halaman Profile
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        currentUserRole: widget.currentUserRole,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                } else {
                  _searchFocusNode.unfocus();
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF005BC0),
              unselectedItemColor: const Color(0xFF414754),
              selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle),
                  label: 'Report',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}