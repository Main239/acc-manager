import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'screens/home_screen.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo trước khi dùng sqflite
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo database
  await DatabaseHelper.instance.database;

  runApp(const AccountManagerApp());
}

class AccountManagerApp extends StatelessWidget {
  const AccountManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Tài Khoản',
      debugShowCheckedModeBanner: false,

      // ── Material 3 Theme ──
      themeMode: ThemeMode.system, // Tự động chuyển Darks\/Light theo hệ thống

      // ── Light Theme ──
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6750A4), // Màu tím Material 3
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),

      // ── Dark Theme ──
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
