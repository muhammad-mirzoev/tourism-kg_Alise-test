class CommentsModel {
  int id;
  List<String> comments;

  CommentsModel({required this.id, required this.comments});

  factory CommentsModel.fromMap(Map<String, dynamic> data) {
    return CommentsModel(id: data["id"], comments: data["comments"]);
  }
  Map<String, dynamic> toMap() => {"id": id, "comments": comments};
}
