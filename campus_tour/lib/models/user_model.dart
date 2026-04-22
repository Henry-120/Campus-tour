class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '冒險者',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nickname,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
