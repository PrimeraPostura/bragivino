import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Future<double> _getAverageRating() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('wines')
        .get();

    double totalRating = 0;
    int count = 0;

    for (var doc in snapshot.docs) {
      totalRating += doc['valoracion'];
      count++;
    }

    return count == 0 ? 0 : totalRating / count;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _getAverageRating(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final averageRating = snapshot.data ?? 0;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Valoración Promedio: $averageRating'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
