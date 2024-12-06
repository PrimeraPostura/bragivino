import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Asegúrate de importar FirebaseAuth
import 'package:bragivino/login/login_screen.dart';
import 'package:bragivino/screens/home_screen.dart';
import 'firebase_options.dart'; // Asegúrate de importar correctamente este archivo

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
      home:
          AuthCheck(), // Reemplaza la pantalla principal por el verificador de autenticación
      routes: {
        '/home': (context) =>
            HomeScreen(), // Ruta a la pantalla de inicio después de login
        '/login': (context) =>
            LoginScreen(), // Ruta de login en caso de que el usuario no esté autenticado
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  // Verificar si el usuario está autenticado al iniciar la app
  void _checkAuth() async {
    await Future.delayed(Duration(
        seconds:
            2)); // Esperamos un breve momento para asegurarnos de que todo esté cargado

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si el usuario está autenticado, navegar al Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Si no está autenticado, navegar al Login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Mientras se verifica el estado de autenticación
      ),
    );
  }
}
