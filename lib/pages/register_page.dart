import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedGender;
  final List<String> genderOptions = ['Masculino', 'Femenino', 'Otro'];
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _ageErrorMessage; // Variable para almacenar el mensaje de error de la edad

  Future<void> register() async {
    setState(() {
      _isLoading = true;
    });

    final name = nameController.text.trim();
    final ageText = ageController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || ageText.isEmpty || email.isEmpty || password.isEmpty || selectedGender == null) {
      _showErrorDialog('Todos los campos son obligatorios');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    int? age = int.tryParse(ageText);
    if (age == null || age < 18) {
      setState(() {
        _ageErrorMessage = 'Debes tener al menos 18 años para registrarte';
        _isLoading = false;
      });
      return;
    } else {
      setState(() {
        _ageErrorMessage = null;
      });
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'age': age,
        'email': email,
        'gender': selectedGender,
      });

      Navigator.pushReplacementNamed(context, '/informationUser');
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _validateAge() {
    final ageText = ageController.text.trim();
    int? age = int.tryParse(ageText);

    if (age != null && age < 18) {
      setState(() {
        _ageErrorMessage = 'Debes tener al menos 18 años para registrarte';
      });
    } else {
      setState(() {
        _ageErrorMessage = null;
      });
    }
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.fire,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Regístrate',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildTextField(nameController, 'Nombre', Icons.person),
                    SizedBox(height: 12),
                    _buildTextField(
                      ageController,
                      'Edad',
                      Icons.cake,
                      keyboardType: TextInputType.number,
                      onEditingComplete: _validateAge,
                    ),
                    if (_ageErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _ageErrorMessage!,
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 12),
                    _buildTextField(emailController, 'Correo', Icons.email, keyboardType: TextInputType.emailAddress),
                    SizedBox(height: 12),
                    _buildPasswordTextField(),
                    SizedBox(height: 12),
                    _buildGenderDropdown(),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : register,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.pink)
                          : Text(
                              'Registrarte',
                              style: TextStyle(fontSize: 18, color: Colors.pink),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        '¿Ya tienes una cuenta? Inicia sesión',
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
    VoidCallback? onEditingComplete,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black87),
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Contraseña',
        prefixIcon: Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: selectedGender,
          items: genderOptions.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
            hintText: 'Género',
            border: InputBorder.none,
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
          isExpanded: true,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
