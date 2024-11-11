import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailOrNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn() async {
    final input = emailOrNameController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      showErrorDialog('Email/Nombre y contraseña no pueden estar vacíos');
      return;
    }

    String email = input;

    if (!input.contains('@')) {
      // Si no es un correo, asumimos que es un nombre y buscamos el correo en Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: input)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        showErrorDialog('No se encontró un usuario con este nombre');
        return;
      }

      email = querySnapshot.docs.first['email'];
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      handleAuthError(e);
    }
  }

  void showErrorDialog(String message) {
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

  void handleAuthError(dynamic error) {
    String errorMessage;
    switch (error.code) {
      case 'user-not-found':
        errorMessage = 'No se encontró un usuario con este email o nombre.';
        break;
      case 'wrong-password':
        errorMessage = 'La contraseña es incorrecta. Intenta nuevamente.';
        break;
      case 'invalid-email':
        errorMessage = 'El formato del email es inválido.';
        break;
      case 'user-disabled':
        errorMessage = 'Esta cuenta ha sido deshabilitada.';
        break;
      default:
        errorMessage = 'Ocurrió un error inesperado. Intenta de nuevo.';
        break;
    }
    showErrorDialog(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicia Sesion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailOrNameController,
              decoration: const InputDecoration(labelText: 'Nombre o Correo'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signIn,
              child: const Text('Inicio de Sesion'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('No tienes cuenta Registrate'),
            ),
          ],
        ),
      ),
    );
  }
}
