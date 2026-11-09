class PlaceModel {
  int id;
  String place_name;
  String description;
  List<String> images;
  List<String> tel_contacts;
  List<String> comments;
  double rating;
  List<double> ratings;
  String owner_uid_user;

  PlaceModel({
    required this.id,
    required this.place_name,
    required this.description,
    required this.images,
    required this.tel_contacts,
    required this.comments,
    required this.rating,
    this.ratings = const [],
    required this.owner_uid_user,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> data) {
    return PlaceModel(
      id: data["id"] is int
          ? data["id"]
          : (int.tryParse(data["id"]?.toString() ?? '0') ?? 0),
      place_name: data["place_name"] ?? '',
      description: data["description"] ?? '',
      images: List<String>.from(data["images"] ?? []),
      tel_contacts: List<String>.from(data["tel_contacts"] ?? []),
      comments: List<String>.from(data["comments"] ?? []),
      rating: (data["rating"] as num?)?.toDouble() ?? 0.0,
      ratings: data["ratings"] != null
          ? (data["ratings"] as List).map((e) => (e as num).toDouble()).toList()
          : [],
      owner_uid_user: data["owner_uid_user"] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "place_name": place_name,
    "description": description,
    "images": images,
    "tel_contacts": tel_contacts,
    "comments": comments,
    "rating": rating,
    "ratings": ratings,
    "owner_uid_user": owner_uid_user,
  };
}
