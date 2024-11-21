import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tinder_app_v2/models/content.dart';

class InfoProfile extends StatefulWidget {
  final Content profile;

  const InfoProfile({super.key, required this.profile});

  @override
  // ignore: library_private_types_in_public_api
  _InfoProfileState createState() => _InfoProfileState();
}

class _InfoProfileState extends State<InfoProfile> {
  late String _name;
  late int _age;
  late String _description;
  late String _gender;
  late List<String> _photoUrls; // Todas las fotos del perfil
  late List<String> _preferences;
  double _profileCompletionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    _name = widget.profile.name;
    _age = widget.profile.age ?? 0;
    _description = widget.profile.description ??
        "Sin descripción"; // Cambiado de bio a description
    _gender = widget.profile.gender ?? "Sin especificar";
    _photoUrls = widget.profile.photoUrl;
    _preferences = widget.profile.preferences ?? [];
    _calculateProfileCompletion();
  }

  void _calculateProfileCompletion() {
    int completedFields = 0;
    if (_name.isNotEmpty) completedFields++;
    if (_age > 0) completedFields++;
    if (_description.isNotEmpty) completedFields++;
    if (_gender.isNotEmpty) completedFields++;
    if (_photoUrls.isNotEmpty) completedFields++;
    if (_preferences.isNotEmpty) completedFields++;

    setState(() {
      _profileCompletionPercentage = completedFields / 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("$_name, $_age",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              background: _photoUrls.isNotEmpty
                  ? Image.network(_photoUrls.first, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey,
                      child:
                          const Icon(Icons.person, size: 100, color: Colors.white)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    title: "Sobre mí",
                    content: Text(
                      _description,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Detalles básicos",
                    content: Column(
                      children: [
                        _buildDetailRow(Icons.cake, "Edad", "$_age años"),
                        _buildDetailRow(Icons.person, "Género", _gender),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Galería de Fotos",
                    content: _buildPhotoGallery(),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Intereses",
                    content: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _preferences.map((preference) {
                        return Chip(
                          label: Text(preference),
                          backgroundColor: Colors.pink[100],
                          labelStyle: TextStyle(color: Colors.pink[800]),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Perfil completado",
                    content: LinearPercentIndicator(
                      lineHeight: 20.0,
                      percent: _profileCompletionPercentage,
                      center: Text(
                          "${(_profileCompletionPercentage * 100).toInt()}%"),
                      progressColor: Colors.pink,
                      backgroundColor: Colors.pink[100],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    final galleryPhotos = _photoUrls.length > 1 ? _photoUrls.sublist(1) : [];

    return galleryPhotos.isEmpty
        ? const Text("No hay fotos adicionales.")
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: galleryPhotos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(galleryPhotos[index], fit: BoxFit.cover),
                ),
              );
            },
          );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
