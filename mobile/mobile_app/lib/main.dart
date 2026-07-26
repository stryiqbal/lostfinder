import 'package:flutter/material.dart';
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
  const HomeScreenWithRole({super.key, required this.currentUserRole});

  @override
  State<HomeScreenWithRole> createState() => _HomeScreenWithRoleState();
}

class _HomeScreenWithRoleState extends State<HomeScreenWithRole> {
  late Future<List<ItemModel>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = ApiService.getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LostFinder - (${widget.currentUserRole.toUpperCase()})'),
        backgroundColor: widget.currentUserRole == 'admin' ? Colors.redAccent : Colors.blueAccent,
      ),
      body: FutureBuilder<List<ItemModel>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada laporan barang hilang.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(
                    item.category == 'lost' ? Icons.search : Icons.check_circle,
                    color: item.category == 'lost' ? Colors.red : Colors.green,
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Lokasi: ${item.location} | Pelapor: ${item.userName}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(label: Text(item.status)),
                      if (widget.currentUserRole == 'admin')
                        const IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: null,
                        )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}