import 'package:card_swipe_animation/card_swipe_test.dart';
import 'package:card_swipe_animation/testing/card_swipe_example.dart';
import 'package:card_swipe_animation/widgets/card_swipe.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            // Spacer(),
            // Text(
            //   'Explore Your Testing Gallery Now',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 30,
            //   ),
            // ),
            // Spacer(),
            CardSwipeTest(),
            SizedBox(height: 40),
            CardSwipeStack(),
            // Spacer(),
          ],
        ),
      ),
    );
  }
}
