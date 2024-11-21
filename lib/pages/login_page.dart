import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  bool _isLoading = false;
  bool _isPasswordVisible = false; // Controla la visibilidad de la contraseña

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
      // ignore: use_build_context_synchronously
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
            if (email.isNotEmpty && isValidEmail(email)) {
              try {
                await _auth.sendPasswordResetEmail(email: email);
                showConfirmationDialog(
                    'Se ha enviado un correo para restablecer tu contraseña.');
              } catch (e) {
                showErrorDialog(
                    'Error al enviar el correo de recuperación. Verifica que el correo esté registrado.');
              }
            } else {
              showErrorDialog(
                  'Por favor, introduce un correo válido con formato correcto.');
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    ),
  );
}

bool isValidEmail(String email) {
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return regex.hasMatch(email);
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
        errorMessage = 'Correo o Contraseña incorrectas.';
        break;
    }
    showErrorDialog(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                    const Icon(
                      FontAwesomeIcons.fire,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Inicia Sesión',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextField(
                      controller: emailOrNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Nombre o Correo',
                        prefixIcon: const Icon(Icons.person, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.pink,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'No tienes cuenta? Regístrate',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: resetPassword,
                      child: const Text(
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
