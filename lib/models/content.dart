// lib/models/content.dart
class Content {
  final String name;
  final int? age;
  final String? bio;
  final String? gender;
  final String photoUrl;
  final List<String>? preferences;

  Content({
    required this.name,
    this.age,
    this.bio,
    this.gender,
    required this.photoUrl,
    this.preferences,
  });
}
