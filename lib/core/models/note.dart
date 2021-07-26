class Note {
  final String? id;
  final String title;
  final String description;
  final String? imagePath;
  final DateTime createdTime;
  final List<String>? searchParameters;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.imagePath,
    required this.createdTime,
    this.searchParameters,
  });

  factory Note.fromJSON(Map<String, dynamic> json, String id) {
    return Note(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String,
      imagePath: json['image_path'] as String,
      createdTime: DateTime.tryParse(json['created_time'] as String)!,
    );
  }

  static Map<String, dynamic> toJSON(Note noteModel) {
    return {
      "id": noteModel.id,
      "title": noteModel.title,
      "description": noteModel.description,
      "image_path": noteModel.imagePath,
      "created_time": noteModel.createdTime.toIso8601String(),
      "searchParameters": noteModel.searchParameters,
    };
  }
}
