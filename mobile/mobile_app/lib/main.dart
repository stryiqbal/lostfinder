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

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    setState(() {
      futureItems = ApiService.getItems();
    });
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
        title: Text(
            'LostFinder - (${widget.currentUserRole.toUpperCase()})'),
        backgroundColor: widget.currentUserRole == 'admin'
            ? Colors.redAccent
            : Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshItems,
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada laporan barang.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  // 🖼️ Tampilkan Foto Barang jika ada, jika tidak tampilkan ikon bawaan
                  leading: item.image != null && item.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.image!,
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
                      Chip(label: Text(item.status)),

                      // 🔴 HANYA TAMPIL & BISA DIKLIK JIKA ROLE IS ADMIN
                      if (widget.currentUserRole == 'admin')
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Tampilkan konfirmasi hapus
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
                                _refreshItems(); // Refresh tampilan list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Laporan berhasil dihapus!')),
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