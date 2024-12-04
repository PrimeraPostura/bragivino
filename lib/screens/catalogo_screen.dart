import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _wines = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchQuery = '';

  // Controladores para el pop-up de Añadir botella
  TextEditingController _sizeController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  String _selectedYear = '2024'; // Año por defecto

  @override
  void initState() {
    super.initState();
    _fetchWines();
  }

  // Función para obtener los vinos
  Future<void> _fetchWines() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (_wines.isNotEmpty) {
      querySnapshot = await _firestore
          .collection('wines')
          .orderBy('name')
          .startAfterDocument(_wines.last)
          .limit(20)
          .get();
    } else {
      querySnapshot =
          await _firestore.collection('wines').orderBy('name').limit(20).get();
    }

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _hasMore = false;
      });
    }

    setState(() {
      _isLoading = false;
      _wines.addAll(querySnapshot.docs);
    });
  }

  // Función para filtrar los vinos según la búsqueda
  List<DocumentSnapshot> _filterWines() {
    if (_searchQuery.isEmpty) {
      return _wines;
    } else {
      return _wines.where((wine) {
        String name = wine['name'].toLowerCase();
        String type = wine['type'].toLowerCase();
        String region = wine['region'].toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) ||
            type.contains(_searchQuery.toLowerCase()) ||
            region.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // Mostrar ventana emergente para añadir botella
  void _showAddBottleDialog(DocumentSnapshot wine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Añadir Botella'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector para tamaño
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Tamaño'),
                items: [
                  "Piccolo 20cl",
                  "Media 37.5cl",
                  "Désorée 50cl",
                  "Estándar 75cl",
                  "Litro 1L",
                  "Magnum 1.5L",
                  "Jeroboam 3L",
                  "Réhoboam 4.5L",
                  "5 Litros 5L",
                  "Mathusalem 6L",
                  "Salmanazar 9L",
                  "Baltahazar 12L",
                  "Nabucodonosor 15L",
                  "Melchior 18L",
                  "Melquisedec 30L"
                ].map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (value) {
                  _sizeController.text = value!;
                },
              ),
              // Selector para Añada (año)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Añada'),
                value: _selectedYear,
                items: List.generate(2025 - 1900, (index) {
                  int year = 1900 + index;
                  return DropdownMenuItem(
                    value: year.toString(),
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
                  });
                },
              ),
              // Selector para Cantidad
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para añadir botella a la base de datos con la estructura solicitada
                String userId = FirebaseAuth
                    .instance.currentUser!.uid; // Obtener el ID del usuario
                FirebaseFirestore.instance.collection('my_wines').add({
                  'name': wine['name'], // Solo el nombre del vino
                  'region': wine['region'], // Solo la región
                  'type': wine['type'], // Solo el tipo
                  'year': _selectedYear, // Año del vino
                  'quantity':
                      'x${_quantityController.text}', // Representar la cantidad como 'x1', 'x2', etc.
                  'size': _sizeController.text, // Tamaño del vino
                  'user_id':
                      userId, // Guardar el ID del usuario para asociar la bodega
                });
                Navigator.pop(context);
              },
              child: Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catalogo de Vinos'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar vino...',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          // Lista de vinos
          Expanded(
            child: ListView.builder(
              itemCount: _filterWines().length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filterWines().length) {
                  // Mostramos un indicador de carga si aún hay más vinos por cargar
                  _fetchWines();
                  return Center(child: CircularProgressIndicator());
                }

                var wine = _filterWines()[index];

                return ListTile(
                  leading: Image.asset('vino.jpg', width: 50, height: 50),
                  title: Text(wine['name']),
                  subtitle: Text(
                    '${wine['type']} - ${wine['region']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    // Al presionar un vino, mostramos el pop-up
                    _showAddBottleDialog(wine);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
