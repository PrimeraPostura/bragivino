import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyWinesScreen extends StatelessWidget {
  const MyWinesScreen({super.key});

  // Obtener el ID del usuario actual
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Recupera los vinos del usuario en Firestore
  Future<List<Map<String, dynamic>>> _getUserWines() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser?.uid)
        .collection('wines')
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id, // Asegúrate de obtener el ID del documento
              'data': doc.data() as Map<String, dynamic>
            })
        .toList();
  }

  // Método para eliminar un vino
  Future<void> _deleteWine(BuildContext context, String wineId) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser?.uid)
          .collection('wines')
          .doc(wineId) // Usamos el wineId para eliminar
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vino eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el vino: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getUserWines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tienes vinos en tu bodega'));
        }

        final wines = snapshot.data!;

        return ListView.builder(
          itemCount: wines.length,
          itemBuilder: (context, index) {
            final wine = wines[index];
            final wineData = wine['data']; // Obtener los datos del vino
            final wineId = wine['id']; // Obtener el ID del vino

            return ListTile(
              leading: Icon(Icons.local_bar), // O imagen aquí
              title: Text(wineData['nombre']),
              subtitle: Text('Año: ${wineData['año_cosecha']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteWine(
                      context, wineId); // Llamamos al método de eliminación
                },
              ),
            );
          },
        );
      },
    );
  }
}
