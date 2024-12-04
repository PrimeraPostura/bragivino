import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyWinesScreen extends StatefulWidget {
  @override
  _MyWinesScreenState createState() => _MyWinesScreenState();
}

class _MyWinesScreenState extends State<MyWinesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _myWines = [];
  bool _isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _fetchMyWines();
  }

  // Función para obtener los vinos de la colección "my_wines" filtrados por user_id
  Future<void> _fetchMyWines() async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser!.uid; // Obtener el ID del usuario
      QuerySnapshot querySnapshot = await _firestore
          .collection('my_wines')
          .where('user_id', isEqualTo: userId) // Filtrar por user_id
          .get();

      setState(() {
        _myWines = querySnapshot.docs;
        _isLoading =
            false; // Cambiar a false una vez que los datos se hayan cargado
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Cambiar a false incluso si hay un error
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al cargar los vinos")));
    }
  }

  // Función para eliminar un vino
  Future<void> _deleteWine(String wineId) async {
    try {
      await _firestore.collection('my_wines').doc(wineId).delete();
      setState(() {
        _myWines.removeWhere((wine) => wine.id == wineId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Vino eliminado")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al eliminar vino")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Vinos'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Indicador de carga mientras se cargan los vinos
          : _myWines.isEmpty
              ? Center(
                  child: Text(
                      'No tienes vinos en tu bodega.')) // Mensaje si no hay vinos
              : ListView.builder(
                  itemCount: _myWines.length,
                  itemBuilder: (context, index) {
                    var wine = _myWines[index];

                    return ListTile(
                      leading: Image.asset('vino.jpg', width: 50, height: 50),
                      title: Text(wine['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${wine['region']}'),
                          Text('${wine['type']}'),
                          Text('${wine['year']}'),
                          Text('${wine['quantity']}'),
                          Text('${wine['size']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteWine(wine.id); // Eliminar vino
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
