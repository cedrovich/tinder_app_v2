import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tinder_app_v2/pages/login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
  List<String> _photoUrls = [];
  List<String> _preferences = [];
  bool _isLoading = true;
  double _profileCompletionPercentage = 0.0;

  final TextEditingController _descriptionController = TextEditingController();

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
            _photoUrls = List<String>.from(snapshot['photos'] ?? []);
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
      // ignore: use_build_context_synchronously
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
      return;
    }

    try {
      File image = File(pickedFile.path);
      final storage = Supabase.instance.client.storage;
      final fileName = pickedFile.path.split('/').last;

      final response = await storage.from('PhotosTAV2').upload(fileName, image,
          fileOptions: const FileOptions(upsert: true));
      if (response.error == null) {
        final publicUrl = storage.from('PhotosTAV2').getPublicUrl(fileName);

        setState(() {
          _photoUrls.add(publicUrl);
        });

        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'photos': _photoUrls,
          });
        }
      } else {
        _showErrorDialog(
            'Error al subir la imagen: ${response.error!.message}');
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
    if (_photoUrls.isNotEmpty) completedFields++;
    if (_preferences.isNotEmpty) completedFields++;

    _profileCompletionPercentage = completedFields / 6;
  }

  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'description': _descriptionController.text,
          'photos': _photoUrls,
          'preferences': _preferences,
        });
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        _loadUserProfile();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el perfil: ${e.toString()}")),
      );
    }
  }

  void _showEditProfileDialog() {
    _descriptionController.text = _description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Center(
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
                    backgroundImage: _photoUrls.isNotEmpty
                        ? NetworkImage(_photoUrls.last)
                        : null,
                    child: _photoUrls.isEmpty
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField("Descripción", _descriptionController),
                const SizedBox(height: 16),
                _buildInterestsSelector(),
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
              child: const Text("Guardar", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

Widget _buildInterestsSelector() {
  final predefinedInterests = [
  'Rock',
  'Pop',
  'Jazz',
  'Clásica',
  'Fútbol',
  'Natación',
  'Yoga',
  'Ciclismo',
  'Ciencia Ficción',
  'Comedia',
  'Terror',
  'Anime',
  'Omar',
  'Vegano',
  'Cocina Italiana',
  'Cocina Mexicana',
  'Sushi',
  'Programación',
  'E-Sports',
  'Juegos de Estrategia',
  'Realidad Virtual',
  'Pintura',
  'Fotografía',
  'Escritura',
  'Lectura',
  'Anuel AA',
  'Gatos',
  'Perros',
  'Caballos',
  'Peces',
  'Arte moderno',
  'Historia',
  'Trans',
  'Medio ambiente',
  'Religión y espiritualidad',
  'Introvertido',
  'Extrovertido',
  'Aventurero',
  'Fitness',
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Intereses",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: predefinedInterests.map((interest) {
          final isSelected = _preferences.contains(interest);
          return ChoiceChip(
            label: Text(interest),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected && !_preferences.contains(interest)) {
                  // Agregar solo si no está ya seleccionado
                  _preferences.add(interest);
                } else if (!selected && _preferences.contains(interest)) {
                  // Eliminar si se deselecciona
                  _preferences.remove(interest);
                }
              });
            },
          );
        }).toList(),
      ),
    ],
  );
}


  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.pink),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesList() {
    if (_preferences.isEmpty) {
      return const Text(
        "No se han seleccionado preferencias.",
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _preferences.map((preference) {
        return Chip(
          label: Text(preference, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.pink,
        );
      }).toList(),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
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
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _photoUrls.isNotEmpty
                            ? Image.network(_photoUrls.last, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey,
                                child: const Icon(Icons.person,
                                    size: 100, color: Colors.white)),
                        Container(
                          decoration: const BoxDecoration(
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
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _showEditProfileDialog,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard("Sobre mí", Text(_description)),
                        const SizedBox(height: 16),
                        _buildCard(
                          "Detalles básicos",
                          Column(
                            children: [
                              _buildDetailRow(Icons.cake, "Edad", "$_age años"),
                              _buildDetailRow(Icons.person, "Género", _gender),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCard("Preferencias", _buildPreferencesList()),
                        const SizedBox(height: 16),
                        _buildCard("Galería de Fotos", _buildPhotoList()),
                        const SizedBox(height: 16),
                        _buildCard(
                          "Perfil completado",
                          LinearPercentIndicator(
                            lineHeight: 20.0,
                            percent: _profileCompletionPercentage,
                            center: Text(
                              "${(_profileCompletionPercentage * 100).toInt()}%",
                              style: const TextStyle(color: Colors.white),
                            ),
                            progressColor: Colors.pink,
                            backgroundColor: Colors.pink[100],
                            animation: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _launchPaymentUrl,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                "Comprar Tinder Gold",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                "Cerrar Sesión",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
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
    final Uri url = Uri.parse('https://buy.stripe.com/test_bIY6qFf4Ogbm9Ow5kk');
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
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

  Widget _buildPhotoList() {
    final galleryPhotos = _photoUrls.length > 1
        ? _photoUrls.sublist(0, _photoUrls.length - 1)
        : [];

    return galleryPhotos.isEmpty
        ? const Text("No has subido fotos adicionales.")
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
}

extension on String {
  get error => null;
}
