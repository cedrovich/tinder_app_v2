import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_screen.dart';
import 'pages/information_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializa Stripe con la clave pública
  Stripe.publishableKey =
      'pk_test_51QL9JwGPBEGVN7yepZ9OtMedcTchh8mZGe9yeWL16sYpJR3bz7XKbzL2jc9zzKskD7m13rRlF9rGIQRXVqT1bFqZ00QvLgPdXR';

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
