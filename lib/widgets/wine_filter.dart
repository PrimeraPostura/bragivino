import 'package:flutter/material.dart';

class WineFilter extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final Function(String) onSearch;

  WineFilter({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Buscar vino',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          onSearch(value);
        },
      ),
    );
  }
}
