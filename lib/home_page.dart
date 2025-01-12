import 'package:card_swipe_animation/helpers/remap.dart';
import 'package:flutter/material.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  /// Record the x-axis position of the card.
  final ValueNotifier<double> _swipeOffset = ValueNotifier<double>(0.0);

  final List<Color> _cardColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Explore Your Testing Gallery Now',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: List.generate(_cardColors.length, (index) {
                return ValueListenableBuilder<double>(
                  valueListenable: _swipeOffset,
                  builder: (context, value, child) {
                    return _buildCard(index, value);
                  },
                );
              }).reversed.toList(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index, double value) {
    if (index == 0) {
      double rotationAngle = value / 200;
      double perspective = 0.003;
      double scale = 1 -
          value
              .clamp(-150.0, 150.0)
              .remap(fromLow: -100, fromHigh: 100, toLow: -0.15, toHigh: 0.15)
              .abs();

      double clampedSwipeOffset = value
          .clamp(-100.0, 100.0)
          .remap(fromLow: -100, fromHigh: 100, toLow: -0.2, toHigh: 0.2)
          .abs();

      return GestureDetector(
        onPanUpdate: (details) {
          _swipeOffset.value += details.delta.dx;
        },
        onPanEnd: (details) {
          if (_swipeOffset.value.abs() > 150) {
            _swipeOffset.value = _swipeOffset.value > 0 ? 500 : -500;
          } else {
            _swipeOffset.value = 0;
          }
        },
        child: Transform(
          transform: Matrix4.identity()
            ..setTranslationRaw(value, 0, 0)
            ..setEntry(3, 2, perspective)
            ..scale(scale)
            ..rotateX(clampedSwipeOffset)
            ..rotateY(rotationAngle),
          alignment: Alignment.center,
          child: _buildCardContainer(_cardColors[index]),
        ),
      );
    }

    if (index == 1) {
      double rotationIndex2 = value.clamp(-100.0, 100.0).remap(
            fromLow: -100,
            fromHigh: 100,
            toLow: -0.4,
            toHigh: 0,
          );

      return Transform(
        transform: Matrix4.identity()..rotateZ(rotationIndex2)
        // ..scale(1)
        ,
        alignment: Alignment.center,
        child: _buildCardContainer(
          _cardColors[index],
        ),
      );
    }

    // if (index == 2) {
    //   return Transform(
    //     transform: Matrix4.identity()..rotateZ(-0.2),
    //     alignment: Alignment.center,
    //     child: _buildCardContainer(
    //       _cardColors[index],
    //     ),
    //   );
    // }

    return _buildCardContainer(_cardColors[index]);
  }

  /// Builds a card container with a given color
  Widget _buildCardContainer(Color color) {
    return Container(
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
