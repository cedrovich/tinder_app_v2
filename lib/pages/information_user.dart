import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InformationUserPage extends StatefulWidget {
  @override
  _InformationUserPageState createState() => _InformationUserPageState();
}

class _InformationUserPageState extends State<InformationUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController descriptionController = TextEditingController();
  List<String> photos = []; // Lista para almacenar las URLs de fotos simuladas

  final List<String> preferenceOptions = [
    'Rock', 'Pop', 'Jazz', 'Clásica', 'Reguetón', 'Electrónica', 'Hip Hop', 'Deportes', 'Cine', 'Viajes', 'Tecnología'
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

        // Enviar correo de verificación
        await user.sendEmailVerification();
        showConfirmationDialog(
          'Cuenta creada con éxito. Por favor, revisa tu correo para verificar tu cuenta.'
        );

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        showErrorDialog('Error al guardar la información');
      }
    }
  }

  void addFakePhoto() {
    setState(() {
      photos.add("https://example.com/photo.jpg"); // URL ficticia para la foto
    });
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
      appBar: AppBar(title: Text('Información del Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addFakePhoto, // Simular la carga de una foto
              child: Text('Agregar Foto'),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: photos
                  .map((url) => Image.network(url, width: 100, height: 100))
                  .toList(),
            ),
            SizedBox(height: 20),
            Text('Preferencias'),
            Wrap(
              spacing: 8.0,
              children: preferenceOptions.map((pref) {
                return FilterChip(
                  label: Text(pref),
                  selected: selectedPreferences[pref] ?? false,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedPreferences[pref] = selected;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUserInfo,
              child: Text('Guardar Información'),
            ),
          ],
        ),
      ),
    );
  }
}
