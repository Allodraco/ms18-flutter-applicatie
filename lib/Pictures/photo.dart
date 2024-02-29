// Deze pagina is de photo model pagina
class Photo {
  final String imageUrl;
  String title;
  final DateTime date;
  final String uploader;
  final int likeCount;
  final String contentType;

  Photo({
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.uploader,
    required this.likeCount,
    required this.contentType,
  });

  // Method to update the title
  void updateTitle(String newTitle) {
    title = newTitle;
  }

  // Factory constructor to create Photo from JSON
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      imageUrl: json['imageUrl'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      uploader: json['uploader'],
      likeCount: json['likeCount'],
      contentType: json['contentType'],
    );
  }
}
