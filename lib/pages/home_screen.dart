import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeScreen({super.key});

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> getUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      return snapshot['name'] ?? 'Usuario';
    }
    return 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false, // Evitar retroceder a la pantalla anterior
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pantalla de Inicio'),
          automaticallyImplyLeading: false, // Ocultar el botón de retroceso
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                signOut().then((_) {
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacementNamed(context, '/login');
                });
              },
            ),
          ],
        ),
        body: Center(
          child: FutureBuilder<String>(
            future: getUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text(
                  'Error al cargar el nombre',
                  style: TextStyle(fontSize: 24),
                );
              } else {
                return Text(
                  'Bienvenido, ${snapshot.data}!',
                  style: const TextStyle(fontSize: 24),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
