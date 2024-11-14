import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'home_screen.dart'; // Importa donde tienes la clase Content

class InfoProfile extends StatefulWidget {
  final Content profile; // Recibe el objeto Content en lugar de userId

  const InfoProfile({Key? key, required this.profile}) : super(key: key);

  @override
  _InfoProfileState createState() => _InfoProfileState();
}

class _InfoProfileState extends State<InfoProfile> {
  String _name = "";
  int _age = 0;
  String _description = "";
  String _gender = "";
  List<String> _photos = [];
  List<String> _preferences = [];
  double _profileCompletionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    setState(() {
      _name = widget.profile.name;
      _age = widget.profile.age ?? 0;
      _description = widget.profile.bio ?? "Sin descripción";
      _photos = [widget.profile.photoUrl]; // Foto principal
      _preferences = widget.profile.bio != null ? [widget.profile.bio!] : []; // Ejemplo de preferencias usando bio
      _calculateProfileCompletion();
    });
  }

  void _calculateProfileCompletion() {
    int completedFields = 0;
    if (_name.isNotEmpty) completedFields++;
    if (_age > 0) completedFields++;
    if (_description.isNotEmpty) completedFields++;
    if (_gender.isNotEmpty) completedFields++;
    if (_photos.isNotEmpty) completedFields++;
    if (_preferences.isNotEmpty) completedFields++;

    _profileCompletionPercentage = completedFields / 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _photos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text("$_name, $_age",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    background: Image.network(_photos[0], fit: BoxFit.cover),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sobre mí",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _description,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Detalles básicos",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                _buildDetailRow(
                                    Icons.cake, "Edad", "$_age años"),
                                _buildDetailRow(
                                    Icons.person, "Género", _gender),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Intereses",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: _preferences.map((preference) {
                                    return Chip(
                                      label: Text(preference),
                                      backgroundColor: Colors.pink[100],
                                      labelStyle:
                                          TextStyle(color: Colors.pink[800]),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Perfil completado",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                LinearPercentIndicator(
                                  lineHeight: 20.0,
                                  percent: _profileCompletionPercentage,
                                  center: Text(
                                      "${(_profileCompletionPercentage * 100).toInt()}%"),
                                  progressColor: Colors.pink,
                                  backgroundColor: Colors.pink[100],
                                ),
                              ],
                            ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink),
          SizedBox(width: 8),
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
