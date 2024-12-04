import 'package:bragivino/login/login_screen.dart';
import 'package:bragivino/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importa el archivo firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Asegúrate de que aquí se pasen las opciones correctas
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bragivino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Pantalla de Login por defecto
      routes: {
        '/home': (context) =>
            HomeScreen(), // Ruta a la pantalla de inicio después de login
      },
    );
  }
}
