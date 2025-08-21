import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<bool>((ref) => false);

final appThemeProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(themeProvider);
  final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
  
  return baseTheme.copyWith(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark 
          ? Colors.grey[900] 
          : Colors.grey[100],
      selectedItemColor: isDark 
          ? Colors.lightBlue[200] 
          : Colors.blue,
      unselectedItemColor: isDark 
          ? Colors.grey[500] 
          : Colors.grey[600],
    ),
  );
});