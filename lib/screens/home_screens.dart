import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wines_screen.dart'; // Para el catálogo de vinos
import 'my_wines_screen.dart'; // Para los vinos del usuario
import 'statistics_screen.dart'; // Para las estadísticas

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bragivino - Mi Bodega Personal"),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: user == null
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bienvenido, ${user.email}'),
                  const SizedBox(height: 20),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: const <Widget>[
                        MyWinesScreen(), // Mis Vinos
                        WinesScreen(), // Catálogo de Vinos
                        StatisticsScreen(), // Estadísticas
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Mis Vinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}
