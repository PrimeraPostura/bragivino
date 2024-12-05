import 'package:flutter/material.dart';
import 'mis_vinos_screen.dart'; // Pantalla de "Mis Vinos"
import 'catalogo_screen.dart'; // Pantalla de "Catálogo"
import 'estadisticas_screen.dart'; // Pantalla de "Estadísticas"

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice de la página seleccionada

  // Las pantallas que se mostrarán según la opción seleccionada
  final List<Widget> _screens = [
    MyWinesScreen(), // Pantalla "Mis Vinos"
    CatalogScreen(), // Pantalla "Catálogo"
    StatisticsScreen(), // Pantalla "Estadísticas"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia la página según el índice
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bragivino'),
      ),
      body: _screens[_selectedIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Indica qué ítem está seleccionado
        onTap:
            _onItemTapped, // Función que cambia la pantalla cuando se toca un ítem
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Ícono de "Mis Vinos"
            label: 'Mis Vinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar), // Ícono de "Catálogo"
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Ícono de "Estadísticas"
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}
