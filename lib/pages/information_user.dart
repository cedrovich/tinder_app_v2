import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class InformationUserPage extends StatefulWidget {
  @override
  _InformationUserPageState createState() => _InformationUserPageState();
}

class _InformationUserPageState extends State<InformationUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController descriptionController = TextEditingController();
  List<String> photos = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> preferenceOptions = [
    'Rock',
    'Pop',
    'Jazz',
    'Clásica',
    'Reguetón',
    'Electrónica',
    'Hip Hop',
    'Deportes',
    'Cine',
    'Viajes',
    'Tecnología',
    'Trans',
    'Gay',
    'Futbol',
    'Basquetbol',
    'AnuelAA',
    'Bad Bunny',
    'Taylor Swift'
  ];

  Map<String, bool> selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    selectedPreferences = {for (var pref in preferenceOptions) pref: false};
  }

  Future<void> saveUserInfo() async {
    final user = _auth.currentUser;
    final description = descriptionController.text.trim();

    if (description.isEmpty || photos.isEmpty) {
      showErrorDialog('La descripción y al menos una foto son obligatorias');
      return;
    }

    if (user != null) {
      try {
        final selectedPreferencesList = selectedPreferences.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        await _firestore.collection('users').doc(user.uid).update({
          'description': description,
          'photos': photos,
          'preferences': selectedPreferencesList,
        });

        await user.sendEmailVerification();
        showConfirmationDialog(
            'Cuenta creada con éxito. Por favor, revisa tu correo para verificar tu cuenta.');

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        showErrorDialog('Error al guardar la información: $e');
      }
    }
  }

  Future<void> addPhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        showErrorDialog("No se seleccionó ninguna imagen.");
        return;
      }

      File image = File(pickedFile.path);
      final storage = Supabase.instance.client.storage;
      final fileName = pickedFile.path.split('/').last;

      final response = await storage.from('PhotosTAV2').upload(fileName, image);
      if (response.error == null) {
        final publicUrl = storage.from('PhotosTAV2').getPublicUrl(fileName);
        setState(() {
          photos.add(publicUrl);
        });
      } else {
        showErrorDialog('Error al subir la imagen: ${response.error!.message}');
      }
    } catch (e) {
      showErrorDialog('Error al seleccionar o subir la imagen: $e');
    }
  }

  void showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmación de cuenta'),
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

  void showErrorDialog(String message) {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.pink, Colors.orange],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      FontAwesomeIcons.fire,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Completa tu perfil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: addPhoto,
                    icon: Icon(Icons.add_a_photo, color: Colors.pink),
                    label: Text('Agregar Foto',
                        style: TextStyle(color: Colors.pink)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: photos
                        .map((url) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(url,
                                  width: 100, height: 100, fit: BoxFit.cover),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Tus intereses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: preferenceOptions.map((pref) {
                      return FilterChip(
                        label: Text(pref),
                        selected: selectedPreferences[pref] ?? false,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedPreferences[pref] = selected;
                          });
                        },
                        selectedColor: Colors.pink.shade200,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: saveUserInfo,
                      child: Text(
                        'Guardar Información',
                        style: TextStyle(fontSize: 18, color: Colors.pink),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  get error => null;
}
