import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Home'))),
    ),
    GoRoute(
      path: '/new-count',
      builder: (context, state) => const Scaffold(body: Center(child: Text('New Count'))),
    ),
    GoRoute(
      path: '/my-counts',
      builder: (context, state) => const Scaffold(body: Center(child: Text('My Counts'))),
    ),
  ],
);