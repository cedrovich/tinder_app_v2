import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_screen.dart';
import 'pages/information_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp();

  // Configura la URL y la clave de Supabase
  const supabaseUrl = 'https://dfxsyhfnremhdinfixqk.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmeHN5aGZucmVtaGRpbmZpeHFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE2MTcwMDgsImV4cCI6MjA0NzE5MzAwOH0.HjdBiZLO8r-O3DrqxaH4UlL1xz44W9JfxNNaI8P_T4g';

  // Inicializa Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // Inicializa Stripe con la clave pública
  Stripe.publishableKey =
      'pk_test_51QL9JwGPBEGVN7yepZ9OtMedcTchh8mZGe9yeWL16sYpJR3bz7XKbzL2jc9zzKskD7m13rRlF9rGIQRXVqT1bFqZ00QvLgPdXR';

  // Ejecuta la aplicación
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/informationUser': (context) => InformationUserPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
