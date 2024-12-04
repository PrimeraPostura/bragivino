import 'package:flutter/material.dart';

class WineCard extends StatelessWidget {
  final String name;
  final int year;
  final String photo;
  final double rating;

  WineCard({
    required this.name,
    required this.year,
    required this.photo,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Image.network(photo),
        title: Text(name),
        subtitle: Text('Año: $year'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.yellow),
            Text(rating.toString(), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
