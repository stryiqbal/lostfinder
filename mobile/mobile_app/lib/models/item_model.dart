class ItemModel {
  final int id;
  final String title;
  final String category;
  final String location;
  final String status;
  final String userName;
  final int? userId;
  final String? userPhoto;
  final String? userEmail;
  final String? userRole;
  final String? image;
  final String? description;
  final DateTime? createdAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.status,
    required this.userName,
    this.userId,
    this.userPhoto,
    this.userEmail,
    this.userRole,
    this.image,
    this.description,
    this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return ItemModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      status: json['status'],
      userName: user != null && user['name'] != null ? user['name'] : 'Anonim',
      userId: user != null ? user['id'] as int? : null,
      userPhoto: user != null ? (user['photo_url'] ?? user['photo'] ?? '') as String? : null,
      userEmail: user != null ? user['email'] as String? : null,
      userRole: user != null ? user['role'] as String? : null,
      image: json['image'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}