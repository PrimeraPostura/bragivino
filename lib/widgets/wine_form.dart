import 'package:flutter/material.dart';

class WineForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final void Function(String, int, String, double) onAddWine;

  // Constructor para pasar la función de agregar vino
  WineForm({Key? key, required this.onAddWine}) : super(key: key);

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
              controller: ratingController,
              decoration: const InputDecoration(labelText: 'Valoración (1-5)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Nota de Cata'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Llama a la función de agregar vino
                final name = nameController.text;
                final year = int.tryParse(yearController.text) ?? 0;
                final rating = double.tryParse(ratingController.text) ?? 0;
                final description = descriptionController.text;
                if (name.isNotEmpty &&
                    year > 0 &&
                    rating > 0 &&
                    description.isNotEmpty) {
                  onAddWine(name, year, description, rating);
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
