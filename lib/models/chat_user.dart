class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.itsOnline,
    required this.createdAt,
    required this.lastActive,
    required this.id,
    required this.email,
    required this.pushToken,
  });
  late String image;
  late String name;
  late String about;
  late bool itsOnline;
  late String createdAt;
  late String lastActive;
  late String id;
  late String email;
  late String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    itsOnline = json['its_online'] ?? '';
    createdAt = json['created_at'] ?? '';
    lastActive = json['last_active'] ?? '';
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['its_online'] = itsOnline;
    data['created_at'] = createdAt;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}
