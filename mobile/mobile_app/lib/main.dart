import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'views/login_screen.dart';
import 'models/item_model.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LostFinder',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFA6F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 📄 WIDGET DETAIL BARANG (Foto Kiri, Teks Kanan)
// ==========================================
class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return 'http://10.0.2.2:8000/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = item.image != null && item.image!.isNotEmpty;
    final isLost = item.category == 'lost';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 500;

              Widget imageSection = ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasImage
                    ? Image.network(
                        _getImageUrl(item.image!),
                        height: isWideScreen ? 320 : 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: isWideScreen ? 320 : 200,
                        color: isLost ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                        child: Center(
                          child: Icon(
                            isLost ? Icons.search_rounded : Icons.check_circle_rounded,
                            size: 64,
                            color: isLost ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                          ),
                        ),
                      ),
              );

              Widget detailSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges (Kategori & Status)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isLost ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isLost ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLost ? Icons.warning_amber_rounded : Icons.verified_rounded,
                              size: 14,
                              color: isLost ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isLost ? 'Barang Hilang' : 'Barang Ditemukan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isLost ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800, // PERBAIKAN: Menggunakan w800 menggantikan extrabold
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Color(0xFFE2E8F0)),
                  ),

                  // Info Lokasi
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFFEF4444),
                    label: 'Lokasi',
                    value: item.location,
                  ),
                  const SizedBox(height: 12),

                  // Info Pelapor
                  _buildDetailRow(
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF2563EB),
                    label: 'Pelapor',
                    value: item.userName,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Color(0xFFE2E8F0)),
                  ),

                  // Deskripsi
                  const Text(
                    'Deskripsi & Ciri-ciri',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (item.description != null && item.description!.isNotEmpty)
                        ? item.description!
                        : 'Tidak ada deskripsi tambahan.',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
                  ),
                ],
              );

              if (isWideScreen) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: imageSection),
                    const SizedBox(width: 20),
                    Expanded(flex: 6, child: detailSection),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageSection,
                    const SizedBox(height: 16),
                    detailSection,
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 🏠 HOME SCREEN
// ==========================================
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

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshItems() {
    setState(() {
      futureItems = ApiService.getItems().then((items) {
        _allItems = items;
        if (_searchController.text.isNotEmpty) {
          _filterItems(_searchController.text);
        } else {
          _filteredItems = items;
        }
        return items;
      });
    });
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        final searchLower = query.toLowerCase();
        _filteredItems = _allItems.where((item) {
          final titleLower = item.title.toLowerCase();
          final locationLower = item.location.toLowerCase();
          return titleLower.contains(searchLower) || locationLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'active':
        return const Color(0xFFDBEAFE);
      case 'resolved':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD97706);
      case 'active':
        return const Color(0xFF2563EB);
      case 'resolved':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return 'http://10.0.2.2:8000/storage/$path';
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = 'lost';
    XFile? pickedImage;
    bool isLoading = false;

    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Buat Laporan Baru',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Nama Barang *',
                        hintText: 'Contoh: Kunci Motor Honda',
                        prefixIcon: const Icon(Icons.card_travel_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'lost', child: Text('Barang Hilang')),
                        DropdownMenuItem(value: 'found', child: Text('Barang Ditemukan')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Lokasi Kejadian *',
                        hintText: 'Contoh: Perpustakaan Lt. 2',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        hintText: 'Ciri-ciri detail barang...',
                        prefixIcon: const Icon(Icons.description_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (image != null) {
                                setModalState(() => pickedImage = image);
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      icon: Icon(
                        pickedImage == null ? Icons.image_search_rounded : Icons.check_circle_rounded,
                        color: pickedImage == null ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                      ),
                      label: Text(
                        pickedImage == null ? 'Unggah Foto Barang' : 'Foto Berhasil Dipilih',
                        style: TextStyle(
                          color: pickedImage == null ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty ||
                              locationController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama barang & lokasi wajib diisi!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isLoading = true);

                          try {
                            final res = await ApiService.addItemWithImage(
                              userId: widget.currentUserId,
                              title: titleController.text.trim(),
                              category: category,
                              description: descriptionController.text.trim(),
                              location: locationController.text.trim(),
                              imageFile: pickedImage,
                            );

                            if (res['success'] == true && mounted) {
                              Navigator.pop(context);
                              _refreshItems();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Laporan berhasil disimpan!'),
                                  backgroundColor: Color(0xFF16A34A),
                                ),
                              );
                            } else {
                              setModalState(() => isLoading = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Gagal menyimpan.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setModalState(() => isLoading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUserRole == 'admin';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HERO BANNER & HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdmin ? 'Admin Dashboard' : 'Pusat Informasi',
                            style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'LostFinder Campus',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                            onPressed: _refreshItems,
                            tooltip: 'Refresh',
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white),
                            tooltip: 'Logout',
                            onPressed: () async {
                              final bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Text('Konfirmasi Logout'),
                                      content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          child: const Text('Logout', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
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
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 18),

                  // SEARCH BAR
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterItems,
                      decoration: InputDecoration(
                        hintText: 'Cari nama barang atau lokasi...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterItems('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LIST ITEMS
            Expanded(
              child: FutureBuilder<List<ItemModel>>(
                future: futureItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text('Gagal memuat data: ${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  if (_allItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inbox_outlined, size: 64, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 12),
                          Text('Belum ada laporan barang.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                        ],
                      ),
                    );
                  }

                  if (_filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 12),
                          Text('Barang tidak ditemukan.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refreshItems(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final hasImage = item.image != null && item.image!.isNotEmpty;
                        final isLost = item.category == 'lost';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailScreen(item: item),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: hasImage
                                          ? Image.network(
                                              _getImageUrl(item.image!),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Container(
                                                width: 80,
                                                height: 80,
                                                color: const Color(0xFFF1F5F9),
                                                child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                                              ),
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: isLost ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                                              child: Icon(
                                                isLost ? Icons.search_rounded : Icons.check_circle_rounded,
                                                color: isLost ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                                                size: 32,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isLost ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isLost ? 'Hilang' : 'Ditemukan',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isLost ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: isAdmin
                                                    ? () async {
                                                        String? selectedStatus = await showDialog<String>(
                                                          context: context,
                                                          builder: (context) => SimpleDialog(
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                            title: const Text('Ubah Status Laporan'),
                                                            children: [
                                                              SimpleDialogOption(
                                                                onPressed: () => Navigator.pop(context, 'pending'),
                                                                child: const Text('🟡 Pending'),
                                                              ),
                                                              SimpleDialogOption(
                                                                onPressed: () => Navigator.pop(context, 'active'),
                                                                child: const Text('🔵 Active'),
                                                              ),
                                                              SimpleDialogOption(
                                                                onPressed: () => Navigator.pop(context, 'resolved'),
                                                                child: const Text('🟢 Resolved'),
                                                              ),
                                                            ],
                                                          ),
                                                        );

                                                        if (selectedStatus != null && selectedStatus != item.status) {
                                                          final res = await ApiService.updateItemStatus(item.id, selectedStatus);
                                                          if (res['success'] == true && mounted) {
                                                            _refreshItems();
                                                          }
                                                        }
                                                      }
                                                    : null,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusBgColor(item.status),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    item.status.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: _getStatusTextColor(item.status),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  item.location,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                                        onPressed: () async {
                                          bool confirm = await showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  title: const Text('Hapus Laporan'),
                                                  content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Batal'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                      child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                                                    ),
                                                  ],
                                                ),
                                              ) ??
                                              false;

                                          if (confirm) {
                                            final res = await ApiService.deleteItem(item.id);
                                            if (res['success'] == true && mounted) {
                                              _refreshItems();
                                            }
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Lapor Barang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}