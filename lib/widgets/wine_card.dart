import 'package:flutter/material.dart';

class WineCard extends StatelessWidget {
  final String name;
  final int year;
  final String? photo; // La foto puede ser opcional
  final double rating;

  // Constructor para pasar los datos del vino
  const WineCard({
    Key? key,
    required this.name,
    required this.year,
    this.photo,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: photo != null
            ? Image.network(photo!)
            : const Icon(Icons.local_bar), // Muestra el icono si no hay foto
        title: Text(name),
        subtitle: Text('Año: $year'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.yellow),
            Text(
              rating.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
