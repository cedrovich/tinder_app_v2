import 'package:flutter/material.dart'; // Importa Flutter para la interfaz de usuario.
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth para manejar la autenticación de usuarios.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Cloud Firestore para almacenar datos de usuarios.
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Importa Font Awesome para usar íconos personalizados.

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key}); // Constructor para la página de registro.

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() =>
      _RegisterPageState(); // Crea el estado asociado a esta página.
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Instancia de Firebase Auth.
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instancia de Firestore.

  // Controladores para los campos de texto.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedGender; // Variable para almacenar el género seleccionado.
  final List<String> genderOptions = [
    'Masculino',
    'Femenino',
    'Otro'
  ]; // Opciones de género.
  bool _isPasswordVisible =
      false; // Controla si la contraseña está visible o no.
  bool _isLoading = false; // Indica si se está procesando la solicitud.
  String?
      _ageErrorMessage; // Almacena mensajes de error relacionados con la edad.

  // Método para registrar al usuario.
  Future<void> register() async {
    setState(() {
      _isLoading = true; // Muestra el indicador de carga.
    });

    final name = nameController.text.trim(); // Obtiene el nombre del usuario.
    final ageText = ageController.text.trim(); // Obtiene la edad como texto.
    final email = emailController.text.trim(); // Obtiene el correo.
    final password = passwordController.text.trim(); // Obtiene la contraseña.

    // Verifica si algún campo está vacío o si no se seleccionó un género.
    if (name.isEmpty ||
        ageText.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        selectedGender == null) {
      _showErrorDialog(
          'Todos los campos son obligatorios'); // Muestra un error.
      setState(() {
        _isLoading = false;
      });
      return;
    }

    int? age = int.tryParse(ageText); // Convierte la edad a entero.
    if (age == null || age < 18) {
      // Verifica si la edad es válida y mayor o igual a 18.
      setState(() {
        _ageErrorMessage = 'Debes tener al menos 18 años para registrarte';
        _isLoading = false;
      });
      return;
    } else {
      setState(() {
        _ageErrorMessage = null; // Limpia cualquier mensaje de error previo.
      });
    }

    try {
      // Crea un usuario en Firebase Auth.
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guarda los datos del usuario en Firestore.
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'age': age,
        'email': email,
        'gender': selectedGender,
      });

      // Navega a la página de información del usuario después del registro.
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/informationUser');
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}'); // Muestra un error si ocurre.
    }

    setState(() {
      _isLoading = false; // Oculta el indicador de carga.
    });
  }

  // Método para validar la edad en tiempo real.
  void _validateAge() {
    final ageText = ageController.text.trim(); // Obtiene la edad ingresada.
    int? age = int.tryParse(ageText); // Convierte la edad a entero.

    if (age != null && age < 18) {
      setState(() {
        _ageErrorMessage =
            'Debes tener al menos 18 años para registrarte'; // Muestra un mensaje de error.
      });
    } else {
      setState(() {
        _ageErrorMessage =
            null; // Limpia el mensaje de error si la edad es válida.
      });
    }
  }

  // Método para mostrar un cuadro de diálogo con mensajes de error.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'), // Título del cuadro de diálogo.
        content: Text(message), // Mensaje de error.
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(), // Cierra el cuadro de diálogo.
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment
                .topRight, // Gradiente de color desde la esquina superior derecha.
            end: Alignment.bottomLeft, // Hasta la esquina inferior izquierda.
            colors: [Colors.pink, Colors.orange], // Colores del gradiente.
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0), // Padding general.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Centra los elementos en el eje principal.
                  children: [
                    const Icon(
                      FontAwesomeIcons.fire, // Ícono de fuego.
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12), // Espaciado.
                    const Text(
                      'Regístrate', // Título de la página.
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(nameController, 'Nombre',
                        Icons.person), // Campo para el nombre.
                    const SizedBox(height: 12),
                    _buildTextField(
                      ageController,
                      'Edad',
                      Icons.cake,
                      keyboardType:
                          TextInputType.number, // Solo acepta números.
                      onEditingComplete:
                          _validateAge, // Valida la edad al completar la edición.
                    ),
                    if (_ageErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _ageErrorMessage!, // Muestra el mensaje de error de la edad.
                          style: const TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 12),
                    _buildTextField(emailController, 'Correo', Icons.email,
                        keyboardType: TextInputType
                            .emailAddress), // Campo para el correo.
                    const SizedBox(height: 12),
                    _buildPasswordTextField(), // Campo para la contraseña.
                    const SizedBox(height: 12),
                    _buildGenderDropdown(), // Dropdown para seleccionar el género.
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ), // Desactiva el botón si está cargando.
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color:
                                  Colors.pink) // Muestra un indicador de carga.
                          : const Text(
                              'Registrarte',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.pink),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Vuelve a la página anterior.
                      },
                      child: const Text(
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

  // Método para construir campos de texto.
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false, // Define si es un campo de contraseña.
    TextInputType? keyboardType, // Tipo de teclado.
    VoidCallback? onEditingComplete, // Acción al completar la edición.
  }) {
    return TextField(
      controller: controller, // Controlador del texto.
      obscureText: isPassword, // Oculta el texto si es una contraseña.
      keyboardType: keyboardType, // Configura el teclado.
      style: const TextStyle(color: Colors.black87),
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey), // Ícono al inicio.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Método para construir el campo de contraseña.
  Widget _buildPasswordTextField() {
    return TextField(
      controller: passwordController,
      obscureText:
          !_isPasswordVisible, // Alterna la visibilidad de la contraseña.
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible =
                  !_isPasswordVisible; // Alterna la visibilidad al presionar.
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

  // Método para construir el selector de género.
  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: selectedGender, // Valor seleccionado.
          items: genderOptions.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender),
            );
          }).toList(), // Opciones disponibles.
          onChanged: (value) {
            setState(() {
              selectedGender = value; // Actualiza el género seleccionado.
            });
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
            hintText: 'Género',
            border: InputBorder.none,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          isExpanded: true,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
