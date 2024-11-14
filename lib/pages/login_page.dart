import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailOrNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
    });

    final input = emailOrNameController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      showErrorDialog('Email/Nombre y contraseña no pueden estar vacíos');
      setState(() {
        _isLoading = false;
      });
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
        setState(() {
          _isLoading = false;
        });
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

    setState(() {
      _isLoading = false;
    });
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
              keyboardType: TextInputType.emailAddress,
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
              Navigator.of(context).pop();
              if (email.isNotEmpty) {
                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  showConfirmationDialog(
                      'Se ha enviado un correo para restablecer tu contraseña.');
                } catch (e) {
                  showErrorDialog(
                      'Error al enviar el correo de recuperación. Verifica que el correo esté registrado.');
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.pink, Colors.orange],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.fire,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 48),
                    Text(
                      'Inicia Sesión',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 48),
                    TextField(
                      controller: emailOrNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Nombre o Correo',
                        prefixIcon: Icon(Icons.person, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : signIn,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 18),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.pink,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'No tienes cuenta? Regístrate',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: resetPassword,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
