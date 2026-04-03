class UserModel {
  final String uid;
  final String email;
  final String nickname;

  UserModel({required this.uid, required this.email, required this.nickname});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      nickname: data['nickname'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
    };
  }
}
