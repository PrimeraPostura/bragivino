import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyWinesScreen extends StatelessWidget {
  const MyWinesScreen({super.key});

  // Obtener el ID del usuario actual
  User? get currentUser => FirebaseAuth.instance.currentUser;

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
    return StreamBuilder<QuerySnapshot>(
      // Utilizamos un stream para escuchar cambios en tiempo real
      stream: FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser?.uid)
          .collection('wines')
          .snapshots(), // Se escucha en tiempo real
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tienes vinos en tu bodega'));
        }

        final wines = snapshot.data!.docs;

        return ListView.builder(
          itemCount: wines.length,
          itemBuilder: (context, index) {
            final wineData = wines[index].data() as Map<String, dynamic>;
            final wineId = wines[index].id; // ID del vino

            return ListTile(
              leading: const Icon(Icons.local_bar), // O una imagen aquí
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
