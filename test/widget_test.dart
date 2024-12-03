import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseTestWidget extends StatefulWidget {
  const FirebaseTestWidget({super.key});

  @override
  State<FirebaseTestWidget> createState() => _FirebaseTestWidgetState();
}

class _FirebaseTestWidgetState extends State<FirebaseTestWidget> {
  String _status = "Initializing Firebase...";

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _status = "Firebase Connected Successfully!";
      });
    } catch (e) {
      setState(() {
        _status = "Firebase Initialization Failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _status,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
