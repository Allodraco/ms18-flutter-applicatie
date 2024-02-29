import 'photo.dart';

// Deze pagina voor category model

class Category {
  String title;
  DateTime date;
  List<Photo> photos;
  List<Category> subAlbums;

  // Placeholder image URL
  static String placeholderImageUrl =
      'https://pic.onlinewebfonts.com/thumbnails/icons_416617.svg';

  Category({
    required this.title,
    required this.date,
    this.photos = const [],
    this.subAlbums = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Assuming the photos are provided in the JSON response
    Iterable list = json['photos'];
    List<Photo> photos =
    List<Photo>.from(list.map((photo) => Photo.fromJson(photo)));

    return Category(
      title: json['title'],
      date: DateTime.parse(json['date']),
      photos: photos,
      // Update the Photo class to use the placeholder image URL if imageUrl is not provided
      subAlbums: (json['subAlbums'] as List<dynamic>?)
          ?.map((subAlbumJson) => Category.fromJson(subAlbumJson))
          .toList() ??
          [],
    );
  }
}
