class UserModel {
  String email;

  UserModel({
    required this.email,
  });

  UserModel.fromMap(Map<String, dynamic> item) : email = item['email'];

  Map<String, Object> toMap() {
    return {
      'email': email,
    };
  }
}
