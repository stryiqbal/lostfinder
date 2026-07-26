import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'views/login_screen.dart';
import 'models/item_model.dart';
import 'services/api_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LostFinder Kampus',
      home: LoginScreen(),
    );
  }
}

// 📄 WIDGET DETAIL BARANG
class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ FOTO BESAR BARANG
            if (item.image != null && item.image!.isNotEmpty)
              Image.network(
                item.image!.startsWith('http')
                    ? item.image!
                    : 'http://127.0.0.1:8000/storage/${item.image}',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.blue.shade50,
                child: Center(
                  child: Icon(
                    item.category == 'lost' ? Icons.search : Icons.check_circle,
                    size: 80,
                    color: item.category == 'lost' ? Colors.red : Colors.green,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷️ KATEGORI & STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        avatar: Icon(
                          item.category == 'lost' ? Icons.warning : Icons.verified,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          item.category == 'lost' ? 'Barang Hilang' : 'Barang Ditemukan',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: item.category == 'lost' ? Colors.redAccent : Colors.green,
                      ),
                      Chip(
                        label: Text(
                          item.status.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: item.status == 'resolved'
                            ? Colors.green
                            : (item.status == 'active' ? Colors.blue : Colors.amber.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 📝 NAMA BARANG
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  const Divider(),

                  // 📍 LOKASI
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on, color: Colors.redAccent),
                    title: const Text('Lokasi Kejadian/Penemuan'),
                    subtitle: Text(item.location, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),

                  // 👤 PELAPOR
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: Colors.blueAccent),
                    title: const Text('Dilaporkan Oleh'),
                    subtitle: Text(item.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),

                  const Divider(),
                  const SizedBox(height: 8),

                  // 📄 DESKRIPSI LENGKAP
                  const Text(
                    'Deskripsi Laporan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (item.description != null && item.description!.isNotEmpty)
                        ? item.description!
                        : 'Tidak ada deskripsi tambahan.',
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🏠 HOME SCREEN
class HomeScreenWithRole extends StatefulWidget {
  final String currentUserRole;
  final int currentUserId; // 👈 Terima ID user yang login

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
  List<ItemModel> _allItems = [];     // Menyimpan seluruh data asli dari API
  List<ItemModel> _filteredItems = []; // Menyimpan data hasil filter pencarian

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false; // Status apakah search bar sedang terbuka/aktif

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    setState(() {
      futureItems = ApiService.getItems().then((items) {
        _allItems = items;
        _filteredItems = items; // Default tampilan berisi seluruh data
        return items;
      });
    });
  }

  // 🔍 Fungsi Filter Laporan berdasarkan Title atau Location
  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          final titleLower = item.title.toLowerCase();
          final locationLower = item.location.toLowerCase();
          final searchLower = query.toLowerCase();

          return titleLower.contains(searchLower) ||
              locationLower.contains(searchLower);
        }).toList();
      }
    });
  }

  // Helper function untuk menentukan warna Chip sesuai status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade700; // 🟡 Kuning/Oranye untuk Pending
      case 'active':
        return Colors.blue;          // 🔵 Biru untuk Active
      case 'resolved':
        return Colors.green;         // 🟢 Hijau untuk Resolved
      default:
        return Colors.grey;
    }
  }

  // 📝 Modal Dialog Form Tambah Laporan dengan Foto
  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = 'lost';
    XFile? pickedImage;

    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // 👈 Digunakan StatefulBuilder agar modal dapat update state lokal
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Buat Laporan Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Barang'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration:
                          const InputDecoration(labelText: 'Kategori'),
                      items: const [
                        DropdownMenuItem(
                          value: 'lost',
                          child: Text('Barang Hilang'),
                        ),
                        DropdownMenuItem(
                          value: 'found',
                          child: Text('Barang Ditemukan'),
                        ),
                      ],
                      onChanged: (val) =>
                          setModalState(() => category = val!),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      decoration:
                          const InputDecoration(labelText: 'Lokasi'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Deskripsi'),
                    ),
                    const SizedBox(height: 12),

                    // 📸 Tombol Pilih Foto
                    ElevatedButton.icon(
                      onPressed: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setModalState(() {
                            pickedImage = image;
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        pickedImage == null
                            ? 'Pilih Foto Barang'
                            : 'Foto Terpilih ✅',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        locationController.text.isEmpty) {
                      return;
                    }

                    // 🚀 Kirim data beserta gambar ke API
                    final res = await ApiService.addItemWithImage(
                      userId: widget.currentUserId,
                      title: titleController.text,
                      category: category,
                      description: descriptionController.text,
                      location: locationController.text,
                      imageFile: pickedImage,
                    );

                    if (res['success'] == true && mounted) {
                      Navigator.pop(context); // Tutup dialog
                      _refreshItems(); // Refresh list barang
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Laporan berhasil ditambahkan!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
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
    return Scaffold(
      appBar: AppBar(
        // 🔍 Jika mode search aktif, tampilkan TextField, jika tidak tampilkan Judul
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari barang atau lokasi...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: _filterItems, // 👈 Panggil filter setiap kali mengetik
              )
            : Text('LostFinder - (${widget.currentUserRole.toUpperCase()})'),
        backgroundColor: widget.currentUserRole == 'admin'
            ? Colors.redAccent
            : Colors.blueAccent,
        actions: [
          // 🔍 Tombol Cari / Tutup Cari
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredItems = _allItems; // Reset pencarian
                } else {
                  _isSearching = true;
                }
              });
            },
            tooltip: _isSearching ? 'Tutup Pencarian' : 'Cari',
          ),

          // 🔄 Tombol Refresh (Sembunyikan saat sedang searching)
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshItems,
              tooltip: 'Refresh Data',
            ),

          // 🚪 Tombol Logout (Sembunyikan saat sedang searching)
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text(
                            'Apakah Anda yakin ingin keluar dari aplikasi?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Logout'),
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
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Berhasil keluar dari akun.')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<List<ItemModel>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (_allItems.isEmpty) {
            return const Center(child: Text('Belum ada laporan barang.'));
          } else if (_filteredItems.isEmpty) {
            // 🔍 Tampilan jika hasil pencarian tidak ditemukan
            return const Center(
              child: Text('Barang yang dicari tidak ditemukan.'),
            );
          }

          // 👈 Tampilkan data dari _filteredItems (bukan snapshot.data!)
          return ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  // 🚀 NAVIGASI KE ITEM DETAIL SCREEN SAAT CARD DIKLIK
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(item: item),
                      ),
                    );
                  },
                  leading: item.image != null && item.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.image!.startsWith('http')
                                ? item.image!
                                : 'http://127.0.0.1:8000/storage/${item.image}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40),
                          ),
                        )
                      : Icon(
                          item.category == 'lost'
                              ? Icons.search
                              : Icons.check_circle,
                          color: item.category == 'lost'
                              ? Colors.red
                              : Colors.green,
                          size: 40,
                        ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Lokasi: ${item.location}\nPelapor: ${item.userName}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🏷️ CHIP STATUS
                      InkWell(
                        onTap: widget.currentUserRole == 'admin'
                            ? () async {
                                String? selectedStatus =
                                    await showDialog<String>(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                    title: const Text('Ubah Status Laporan'),
                                    children: [
                                      SimpleDialogOption(
                                        onPressed: () =>
                                            Navigator.pop(context, 'pending'),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.hourglass_empty,
                                                color: Colors.amber),
                                            SizedBox(width: 10),
                                            Text('🟡 Pending (Menunggu)'),
                                          ],
                                        ),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () =>
                                            Navigator.pop(context, 'active'),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.check_circle_outline,
                                                color: Colors.blue),
                                            SizedBox(width: 10),
                                            Text('🔵 Active (Dipublikasi)'),
                                          ],
                                        ),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () => Navigator.pop(
                                            context, 'resolved'),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.task_alt,
                                                color: Colors.green),
                                            SizedBox(width: 10),
                                            Text('🟢 Resolved (Selesai)'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (selectedStatus != null &&
                                    selectedStatus != item.status) {
                                  final res = await ApiService.updateItemStatus(
                                      item.id, selectedStatus);
                                  if (res['success'] == true && mounted) {
                                    _refreshItems();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Status diubah menjadi $selectedStatus!'),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        child: Chip(
                          label: Text(
                            item.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: _getStatusColor(item.status),
                        ),
                      ),

                      // 🔴 TOMBOL DELETE (Khusus Admin)
                      if (widget.currentUserRole == 'admin')
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hapus Laporan'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus laporan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (confirm) {
                              final res =
                                  await ApiService.deleteItem(item.id);
                              if (res['success'] == true && mounted) {
                                _refreshItems();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Laporan berhasil dihapus!'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // ➕ Floating Button untuk buka Modal Form
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: widget.currentUserRole == 'admin'
            ? Colors.redAccent
            : Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}