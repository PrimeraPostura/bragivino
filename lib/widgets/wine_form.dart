import 'package:flutter/material.dart';

class WineForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final void Function(String, int, String) onAddWine;

  WineForm({required this.onAddWine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Vino")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre del Vino'),
            ),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Año de Cosecha'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: photoController,
              decoration:
                  const InputDecoration(labelText: 'Foto de la Etiqueta (URL)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Llama la función para agregar el vino
                final name = nameController.text;
                final year = int.tryParse(yearController.text) ?? 0;
                final photo = photoController.text;
                if (name.isNotEmpty && year > 0 && photo.isNotEmpty) {
                  onAddWine(name, year, photo);
                  Navigator.pop(context); // Regresa a la pantalla anterior
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor ingrese todos los datos')),
                  );
                }
              },
              child: const Text('Agregar Vino'),
            ),
          ],
        ),
      ),
    );
  }
}
