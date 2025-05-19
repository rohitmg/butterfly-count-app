import 'package:flutter/material.dart';

class MyCountsScreen extends StatelessWidget {
  const MyCountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Counts')),
      body: const Center(child: Text('MY COUNTS SCREEN', style: TextStyle(fontSize: 24))),
    );
  }
}