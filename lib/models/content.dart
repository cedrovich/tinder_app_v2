class Content {
  final String name;
  final int? age;
  final String? description; // Cambiado de bio a description
  final String? gender;
  final List<String> photoUrl;
  final List<String>? preferences;

  Content({
    required this.name,
    this.age,
    this.description, // Cambiado de bio a description
    this.gender,
    required this.photoUrl,
    this.preferences,
  });
}
