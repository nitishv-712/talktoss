class User {
  final String id;
  final String name;
  final String mobile;
  final bool isOnline;

  User({required this.id, required this.name, required this.mobile, this.isOnline = false});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    mobile: json['mobile'],
    isOnline: json['isOnline'] ?? false,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'mobile': mobile, 'isOnline': isOnline};
}
