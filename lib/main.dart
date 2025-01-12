import 'package:card_swipe_animation/home_page.dart';
import 'package:card_swipe_animation/testing.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Card Swipe Animation',
      home: UserHomeScreen(),
      // home: HomePage(),
    );
  }
}
