import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
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
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      handleAuthError(e);
    }
  }

  Future<void> resetPassword() async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Introduce tu correo para recuperar tu contraseña'),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              if (email.isNotEmpty) {
                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  showConfirmationDialog('Se ha enviado un correo para restablecer tu contraseña.');
                } catch (e) {
                  showErrorDialog('Error al enviar el correo de recuperación.');
                }
              } else {
                showErrorDialog('Por favor, introduce un correo válido.');
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperación de Contraseña'),
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
              onPressed: resetPassword,
              child: const Text('¿Olvidaste tu contraseña?'),
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
