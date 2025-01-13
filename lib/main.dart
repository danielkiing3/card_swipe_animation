import 'package:card_swipe_animation/home_page.dart';
import 'package:card_swipe_animation/testing_widget/testing.dart';
import 'package:card_swipe_animation/testing_widget/testing2.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MyApp(),
    // const Testing(),
  );
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

class Testing extends StatelessWidget {
  const Testing({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Card Swipe Animation',
      home: Scaffold(
        body: SwipeableCardStack(
          cards: [
            ExampleCard(color: Colors.blue, text: 'Card 1'),
            ExampleCard(color: Colors.red, text: 'Card 2'),
            ExampleCard(color: Colors.green, text: 'Card 3'),
          ],
          // threshold: 0.3,
        ),
      ),
    );
  }
}
