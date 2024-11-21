// Archivo generado automáticamente por FlutterFire CLI.
// ignore_for_file: type=lint // Ignora reglas de lint para este archivo.

import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions; // Importa FirebaseOptions para configurar Firebase.
import 'package:flutter/foundation.dart'
    show
        defaultTargetPlatform,
        kIsWeb,
        TargetPlatform; // Importa utilidades para detectar la plataforma y si es web.

/// Configuración predeterminada de [FirebaseOptions] para usar con tus apps de Firebase.
///
/// Ejemplo:
/// ```dart
/// import 'firebase_options.dart'; // Importa este archivo para usar FirebaseOptions.
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform, // Inicializa Firebase según la plataforma actual.
/// );
/// ```
class DefaultFirebaseOptions {
  /// Obtiene las opciones de Firebase específicas para la plataforma actual.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Lanza un error si se intenta usar en la web, ya que no está configurado para web.
      throw UnsupportedError(
        'DefaultFirebaseOptions no ha sido configurado para la web - '
        'puedes configurarlo nuevamente ejecutando FlutterFire CLI.',
      );
    }
    // Selecciona las opciones de Firebase según la plataforma detectada.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // Devuelve las opciones específicas para Android.
      case TargetPlatform.iOS:
        // Lanza un error si se intenta usar en iOS, ya que no está configurado para iOS.
        throw UnsupportedError(
          'DefaultFirebaseOptions no ha sido configurado para iOS - '
          'puedes configurarlo nuevamente ejecutando FlutterFire CLI.',
        );
      case TargetPlatform.macOS:
        // Lanza un error si se intenta usar en macOS, ya que no está configurado para macOS.
        throw UnsupportedError(
          'DefaultFirebaseOptions no ha sido configurado para macOS - '
          'puedes configurarlo nuevamente ejecutando FlutterFire CLI.',
        );
      case TargetPlatform.windows:
        // Lanza un error si se intenta usar en Windows, ya que no está configurado para Windows.
        throw UnsupportedError(
          'DefaultFirebaseOptions no ha sido configurado para Windows - '
          'puedes configurarlo nuevamente ejecutando FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        // Lanza un error si se intenta usar en Linux, ya que no está configurado para Linux.
        throw UnsupportedError(
          'DefaultFirebaseOptions no ha sido configurado para Linux - '
          'puedes configurarlo nuevamente ejecutando FlutterFire CLI.',
        );
      default:
        // Lanza un error si la plataforma no es reconocida o no es soportada.
        throw UnsupportedError(
          'DefaultFirebaseOptions no son soportados para esta plataforma.',
        );
    }
  }

  // Configuración específica para Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyDQsY3_01faGyV7FsUBGu23a7ZlRnJJVUw', // Clave de API de Firebase para Android.
    appId:
        '1:382942156780:android:076978e8f3c84a511952c9', // ID de la aplicación de Firebase.
    messagingSenderId:
        '382942156780', // ID del remitente de mensajes de Firebase Cloud Messaging.
    projectId: 'tinderappv2', // ID del proyecto de Firebase.
    storageBucket:
        'tinderappv2.firebasestorage.app', // URL del bucket de almacenamiento de Firebase.
  );
}
