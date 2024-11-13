import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = "";
  int _age = 0;
  String _description = "";
  String _gender = "";
  String _photoUrl = "";
  List<String> _preferences = [];
  bool _isLoading = true;
  double _profileCompletionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            _name = snapshot['name'] ?? "Sin nombre";
            _age = snapshot['age'] ?? 0;
            _description = snapshot['description'] ?? "Sin descripción";
            _gender = snapshot['gender'] ?? "Sin especificar";
            _photoUrl = snapshot['photos']?.isNotEmpty == true
                ? snapshot['photos'][0]
                : "";
            _preferences = List<String>.from(snapshot['preferences'] ?? []);
            _isLoading = false;
            _calculateProfileCompletion();
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al cargar el perfil: ${e.toString()}"),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateProfileCompletion() {
    int completedFields = 0;
    if (_name.isNotEmpty) completedFields++;
    if (_age > 0) completedFields++;
    if (_description.isNotEmpty) completedFields++;
    if (_gender.isNotEmpty) completedFields++;
    if (_photoUrl.isNotEmpty) completedFields++;
    if (_preferences.isNotEmpty) completedFields++;

    _profileCompletionPercentage = completedFields / 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
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
                    background: _photoUrl.isNotEmpty
                        ? Image.network(_photoUrl, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey,
                            child: Icon(Icons.person,
                                size: 100, color: Colors.white)),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // Acción de editar perfil
                      },
                    ),
                  ],
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
