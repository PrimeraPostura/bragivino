import 'package:bragivino/screens/add_wine_screen.dart';
import 'package:bragivino/screens/home_screens.dart';
import 'package:bragivino/screens/login_screen.dart';
import 'package:bragivino/screens/my_wines_screen.dart';
import 'package:bragivino/screens/statistics_screen.dart';
import 'package:bragivino/screens/wines_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Importa el archivo de configuración de Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Usamos la configuración generada de Firebase
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // La pantalla inicial es de login
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/wines': (context) => const WinesScreen(),
        '/add_wine': (context) => const AddWineScreen(),
        '/my_wines': (context) => const MyWinesScreen(),
        '/statistics': (context) => const StatisticsScreen(),
      },
    );
  }
}
