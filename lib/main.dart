import 'package:flutter/material.dart'; // Importa el paquete principal de Flutter para crear interfaces de usuario.
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase para inicializar y usar sus servicios.
import 'package:flutter_stripe/flutter_stripe.dart'; // Importa la biblioteca de Stripe para manejar pagos en Flutter.
import 'package:supabase_flutter/supabase_flutter.dart'; // Importa la biblioteca de Supabase para gestionar la base de datos y autenticación.
import 'pages/login_page.dart'; // Importa la página de inicio de sesión.
import 'pages/register_page.dart'; // Importa la página de registro.
import 'pages/home_screen.dart'; // Importa la página de inicio (dashboard).
import 'pages/information_user.dart'; // Importa la página de información del usuario.

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que los widgets de Flutter estén inicializados antes de ejecutar cualquier código asíncrono.

  // Inicializa Firebase
  await Firebase
      .initializeApp(); // Configura e inicializa Firebase para su uso en la aplicación.

  // Configura la URL y la clave de Supabase
  const supabaseUrl =
      'https://dfxsyhfnremhdinfixqk.supabase.co'; // URL de tu proyecto de Supabase.
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmeHN5aGZucmVtaGRpbmZpeHFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE2MTcwMDgsImV4cCI6MjA0NzE5MzAwOH0.HjdBiZLO8r-O3DrqxaH4UlL1xz44W9JfxNNaI8P_T4g'; // Clave pública (anonKey) de tu proyecto de Supabase.

  // Inicializa Supabase
  await Supabase.initialize(
    url: supabaseUrl, // Configura la URL del proyecto de Supabase.
    anonKey: supabaseKey, // Configura la clave pública (anonKey) de Supabase.
  );

  // Inicializa Stripe con la clave pública
  Stripe.publishableKey =
      'pk_test_51QL9JwGPBEGVN7yepZ9OtMedcTchh8mZGe9yeWL16sYpJR3bz7XKbzL2jc9zzKskD7m13rRlF9rGIQRXVqT1bFqZ00QvLgPdXR'; // Configura la clave pública de Stripe para manejar pagos.

  // Ejecuta la aplicación
  runApp(
      const MyApp()); // Llama a la clase principal `MyApp` para iniciar la aplicación.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Login', // Título de la aplicación.
      theme: ThemeData(
        primarySwatch: Colors
            .blue, // Define el tema de la aplicación con el color azul como base.
      ),
      debugShowCheckedModeBanner:
          false, // Oculta la marca de depuración en la esquina superior derecha.
      initialRoute:
          '/login', // Define la ruta inicial como la página de inicio de sesión.
      routes: {
        '/login': (context) =>
            const LoginPage(), // Ruta para la página de inicio de sesión.
        '/register': (context) =>
            const RegisterPage(), // Ruta para la página de registro.
        '/informationUser': (context) =>
            const InformationUserPage(), // Ruta para la página de información del usuario.
        '/home': (context) =>
            const HomeScreen(), // Ruta para la página principal (dashboard).
      },
    );
  }
}
