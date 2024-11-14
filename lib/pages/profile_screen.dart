import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String _name = "";
  int _age = 0;
  String _description = "";
  String _gender = "";
  String _photoUrl = "";
  List<String> _preferences = [];
  bool _isLoading = true;
  double _profileCompletionPercentage = 0.0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

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

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return; // El usuario no seleccionó ninguna imagen
    }

    try {
      File image = File(pickedFile.path);
      final storage = Supabase.instance.client.storage;
      final fileName = pickedFile.path.split('/').last;

      // Subir la imagen a Supabase permitiendo imágenes repetidas
      final response = await storage.from('PhotosTAV2').upload(fileName, image, fileOptions: const FileOptions(upsert: true));
      if (response.error == null) {
        final publicUrl = storage.from('PhotosTAV2').getPublicUrl(fileName);
        
        setState(() {
          _photoUrl = publicUrl;
        });

        // Actualizar la URL de la foto en Firestore
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'photos': [_photoUrl],
          });
        }
      } else {
        _showErrorDialog('Error al subir la imagen: ${response.error!.message}');
      }
    } catch (e) {
      _showErrorDialog('Error al seleccionar o subir la imagen: $e');
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

  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'description': _descriptionController.text,
          'gender': _genderController.text,
          'photos': [_photoUrl],
          'preferences': _preferences,
        });
        Navigator.of(context).pop(); // Cierra el diálogo después de guardar
        _loadUserProfile(); // Recarga el perfil después de la actualización
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el perfil: ${e.toString()}")),
      );
    }
  }

  void _showEditProfileDialog() {
    _nameController.text = _name;
    _ageController.text = _age.toString();
    _descriptionController.text = _description;
    _genderController.text = _gender;
    _photoUrlController.text = _photoUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              "Editar Perfil",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _photoUrl.isNotEmpty
                        ? NetworkImage(_photoUrl)
                        : null,
                    child: _photoUrl.isEmpty
                        ? Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField("Nombre", _nameController),
                _buildTextField("Edad", _ageController, TextInputType.number),
                _buildTextField("Descripción", _descriptionController),
                _buildTextField("Género", _genderController),
                _buildTextField("URL de Foto", _photoUrlController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancelar",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text("Guardar", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      [TextInputType? type]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.pink),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text("$_name, $_age",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _photoUrl.isNotEmpty
                            ? Image.network(_photoUrl, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey,
                                child: Icon(Icons.person,
                                    size: 100, color: Colors.white)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        _showEditProfileDialog();
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
                        _buildCard("Sobre mí", Text(_description)),
                        SizedBox(height: 16),
                        _buildCard(
                          "Detalles básicos",
                          Column(
                            children: [
                              _buildDetailRow(Icons.cake, "Edad", "$_age años"),
                              _buildDetailRow(Icons.person, "Género", _gender),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildCard(
                          "Intereses",
                          Wrap(
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
                        SizedBox(height: 16),
                        _buildCard(
                          "Perfil completado",
                          LinearPercentIndicator(
                            lineHeight: 20.0,
                            percent: _profileCompletionPercentage,
                            center: Text(
                              "${(_profileCompletionPercentage * 100).toInt()}%",
                              style: TextStyle(color: Colors.white),
                            ),
                            progressColor: Colors.pink,
                            backgroundColor: Colors.pink[100],
                            animation: true,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _launchPaymentUrl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            "Comprar Tinder Gold",
                            style: TextStyle(fontSize: 16, color: Colors.white),
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

  Future<void> _launchPaymentUrl() async {
    final Uri url =
        Uri.parse('https://buy.stripe.com/test_bIY6qFf4Ogbm9Ow5kk'); // URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  Widget _buildCard(String title, Widget content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            content,
          ],
        ),
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

extension on String {
  get error => null;
}
