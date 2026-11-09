class UserModel {
  String uid;
  String nickname;
  String user_contact_number;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.user_contact_number,
  });
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data["uid"],
      nickname: data["nickname"],
      user_contact_number: data["user_contact_number"],
    );
  }
  Map<String, dynamic> toMap() => {
    "uid": uid,
    "nickname": nickname,
    "user_contact_number": user_contact_number,
  };
}
