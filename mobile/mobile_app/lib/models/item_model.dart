class ItemModel {
  final int id;
  final String title;
  final String category;
  final String location;
  final String status;
  final String userName;
  final String? image;
  final String? description;

  ItemModel({required this.id, required this.title, required this.category, required this.location, required this.status, required this.userName, this.image, this.description,});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      status: json['status'],
      userName: json['user'] != null ? json['user']['name'] : 'Anonim',
      image: json['image'],
      description: json['description'],
    );
  }
}