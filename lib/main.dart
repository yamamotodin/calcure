import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CalcureApp());
}

class CalcureApp extends StatelessWidget {
  const CalcureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'けいさんれんしゅう',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
