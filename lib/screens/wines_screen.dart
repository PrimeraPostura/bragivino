import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WinesScreen extends StatefulWidget {
  const WinesScreen({Key? key}) : super(key: key);

  @override
  _WinesScreenState createState() => _WinesScreenState();
}

class _WinesScreenState extends State<WinesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Método para buscar vinos en el catálogo de Firebase
  Stream<QuerySnapshot> _searchWines() {
    return FirebaseFirestore.instance
        .collection('wine_catalog')
        .where('nombre', isGreaterThanOrEqualTo: _searchQuery)
        .where('nombre', isLessThan: _searchQuery + 'z')
        .snapshots();
  }

  // Método para agregar el vino al inventario del usuario
  Future<void> _addWineToMyCollection(Map<String, dynamic> wineData) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario no autenticado")),
      );
      return;
    }

    try {
      // Agregar el vino a la colección del usuario
      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .collection('wines')
          .add({
        'nombre': wineData['nombre'],
        'año_cosecha': wineData['año_cosecha'],
        'nota_cata': wineData['nota_cata'],
        'valoracion': wineData['valoracion'],
        'region': wineData['region'],
        'bodega': wineData['bodega'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vino agregado a tu bodega")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar el vino: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catálogo de Vinos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar vino',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            // Vinos del catálogo
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _searchWines(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final wines = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: wines.length,
                    itemBuilder: (context, index) {
                      final wineData =
                          wines[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.local_bar), // O imagen aquí
                          title: Text(wineData['nombre']),
                          subtitle: Text('Año: ${wineData['año_cosecha']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              // Llamamos al método para agregar vino a "Mis vinos"
                              _addWineToMyCollection(wineData);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
