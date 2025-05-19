import 'package:flutter/material.dart';

class ButterflyCountForm extends StatelessWidget {
  const ButterflyCountForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Count')),
      body: const Center(child: Text('BUTTERFLY COUNT FORM', style: TextStyle(fontSize: 24))),
    );
  }
}