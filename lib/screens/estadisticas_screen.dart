import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<DocumentSnapshot> _myWines = [];
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Cargar el ID del usuario autenticado
  Future<void> _loadUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _loadWines();
    }
  }

  // Función para cargar los vinos del usuario desde Firestore
  Future<void> _loadWines() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('my_wines')
        .where('user_id',
            isEqualTo: _userId) // Filtramos por el user_id del usuario actual
        .get();

    setState(() {
      _myWines = querySnapshot.docs;
    });
  }

  // Vino Más Viejo en la Bodega con más detalles
  String _oldestWineDetails() {
    if (_myWines.isEmpty) {
      return 'No hay vinos en la bodega';
    }

    DocumentSnapshot oldestWine = _myWines[0];
    String wineName = oldestWine['name'];
    String wineYear = oldestWine['year'].toString();
    String wineQuantity = oldestWine['quantity'];
    String wineSize = oldestWine['size'];

    for (var wine in _myWines) {
      int wineYear = int.tryParse(wine['year'].toString()) ?? 0;
      int currentOldestYear = int.tryParse(oldestWine['year'].toString()) ?? 0;

      if (wineYear < currentOldestYear) {
        oldestWine = wine;
      }
    }

    // Extraemos la cantidad y el tamaño
    int quantity = _parseQuantity(oldestWine['quantity']);
    double size = _parseSize(oldestWine['size']);
    double totalSize = size * quantity;

    return '''
Vino: $wineName
Año: $wineYear
Cantidad: $wineQuantity
Tamaño: $wineSize
Tamaño Total: ${totalSize.toStringAsFixed(2)}L
''';
  }

  // Cantidad Total de Vino en la Bodega
  String _totalWineQuantity() {
    if (_myWines.isEmpty) {
      return 'No hay vinos en la bodega';
    }

    int totalQuantity = 0;

    for (var wine in _myWines) {
      String quantity = wine['quantity'];
      int wineQuantity = int.tryParse(quantity.replaceAll('x', '').trim()) ?? 0;
      totalQuantity += wineQuantity;
    }

    return 'Cantidad Total: x$totalQuantity';
  }

  // Distribución por Tipo de Vino
  Map<String, int> _wineTypeDistribution() {
    Map<String, int> distribution = {};

    for (var wine in _myWines) {
      String type = wine['type'];
      distribution[type] = (distribution[type] ?? 0) + 1;
    }

    return distribution;
  }

  // Vino con Mayor Cantidad en la Bodega
  String _wineWithMostQuantity() {
    if (_myWines.isEmpty) {
      return 'No hay vinos en la bodega';
    }

    DocumentSnapshot wineWithMostQuantity = _myWines[0];
    int maxQuantity = _parseQuantity(wineWithMostQuantity['quantity']);

    for (var wine in _myWines) {
      int wineQuantity = _parseQuantity(wine['quantity']);
      if (wineQuantity > maxQuantity) {
        wineWithMostQuantity = wine;
        maxQuantity = wineQuantity;
      }
    }

    return wineWithMostQuantity['name'];
  }

  // Parse quantity from 'x5', 'x2', etc. into integer
  int _parseQuantity(String quantity) {
    return int.tryParse(quantity.replaceAll('x', '').trim()) ?? 0;
  }

  // Tamaño Total de la Bodega
  String _totalWineSize() {
    if (_myWines.isEmpty) {
      return 'No hay vinos en la bodega';
    }

    double totalSize = 0.0;

    for (var wine in _myWines) {
      String size = wine['size'];
      double wineSize = _parseSize(size);
      int quantity =
          _parseQuantity(wine['quantity']); // Obtener cantidad de botellas
      totalSize += wineSize * quantity; // Multiplicamos tamaño por cantidad
    }

    return 'Tamaño Total: ${totalSize.toStringAsFixed(2)}L';
  }

  // Parse size (e.g., 'Réhoboam 4.5L') into a double (litros)
  double _parseSize(String size) {
    // Definir un mapa de tamaños que puedas reconocer fácilmente
    Map<String, double> sizeMap = {
      "Piccolo 20cl": 0.20,
      "Media 37.5cl": 0.375,
      "Désorée 50cl": 0.50,
      "Estándar 75cl": 0.75,
      "Litro 1L": 1.0,
      "Magnum 1.5L": 1.5,
      "Jeroboam 3L": 3.0,
      "Réhoboam 4.5L": 4.5,
      "5 Litros 5L": 5.0,
      "Mathusalem 6L": 6.0,
      "Salmanazar 9L": 9.0,
      "Baltahazar 12L": 12.0,
      "Nabucodonosor 15L": 15.0,
      "Melchior 18L": 18.0,
      "Melquisedec 30L": 30.0,
    };

    // Si el tamaño existe en el mapa, devuelve el valor correspondiente
    if (sizeMap.containsKey(size)) {
      return sizeMap[size] ?? 0.0;
    }

    // Si no se encuentra el tamaño, retornar 0.0 por defecto
    return 0.0;
  }

  // Función para mostrar un Dialog con el contenido de la estadística
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el dialog
              },
              child: Text('Cerrar'),
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
        title: Text('Estadísticas de Vinos'),
      ),
      body: _myWines.isEmpty
          ? Center(
              child: Text(
                'Tu bodega está vacía.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón para mostrar el Vino Más Viejo
                  ElevatedButton(
                    onPressed: () {
                      _showDialog(
                        'Vino Más Viejo',
                        _oldestWineDetails(),
                      );
                    },
                    child: Text('Vino Más Viejo'),
                  ),
                  SizedBox(height: 10),
                  // Botón para mostrar la Cantidad Total de Vino
                  ElevatedButton(
                    onPressed: () {
                      _showDialog(
                        'Cantidad Total de Vino',
                        _totalWineQuantity(),
                      );
                    },
                    child: Text('Cantidad Total de Vino'),
                  ),
                  SizedBox(height: 10),
                  // Botón para mostrar el Vino con Mayor Cantidad
                  ElevatedButton(
                    onPressed: () {
                      _showDialog(
                        'Vino con Mayor Cantidad',
                        _wineWithMostQuantity(),
                      );
                    },
                    child: Text('Vino con Mayor Cantidad'),
                  ),
                  SizedBox(height: 10),
                  // Botón para mostrar el Tamaño Total de la Bodega
                  ElevatedButton(
                    onPressed: () {
                      _showDialog(
                        'Tamaño Total de la Bodega',
                        _totalWineSize(),
                      );
                    },
                    child: Text('Tamaño Total de la Bodega'),
                  ),
                  SizedBox(height: 10),
                  // Botón para mostrar la Distribución por Tipo de Vino
                  ElevatedButton(
                    onPressed: () {
                      _showDialog(
                        'Distribución por Tipo de Vino',
                        _wineTypeDistribution().entries.map((entry) {
                          return '${entry.key}: ${entry.value}';
                        }).join('\n'),
                      );
                    },
                    child: Text('Distribución por Tipo de Vino'),
                  ),
                ],
              ),
            ),
    );
  }
}
