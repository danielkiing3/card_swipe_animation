import 'package:card_swipe_animation/helpers/remap.dart';
import 'package:card_swipe_animation/helpers/spring_simulation.dart';
import 'package:flutter/material.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  /// Spring simulation for the card swipe animation
  late final SpringSimulation2D _springSimulation;

  final List<Color> _cardColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    // Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();

    _springSimulation = SpringSimulation2D(
      tickerProvider: this,
      spring: const SpringDescription(
        mass: 20,
        stiffness: 10,
        damping: 1,
      ),
    );
  }

  @override
  void dispose() {
    _springSimulation.dispose();
    super.dispose();
  }

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
              children: List.generate(3, (index) {
                return ListenableBuilder(
                  listenable: _springSimulation,
                  builder: (context, child) {
                    return _buildCard(
                        index, _springSimulation.springPosition.dx);
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

  void _moveTopCardToBack() {
    if (_cardColors.isNotEmpty) {
      // Remove the top card
      Color removedCard = _cardColors.removeAt(0);

      // Add it to the back of the stack
      _cardColors.add(removedCard);
    }
  }

  Widget _buildCard(int index, double value) {
    double maxOffset = 200;
    double clampedValue = value.clamp(-maxOffset, maxOffset);

    /// Top card
    if (index == 0) {
      double rotationAngle = value / 200;
      double perspective = 0.003;

      /// Scale the card based on the x-axis position
      double cardScaleFactor = 1 -
          clampedValue
              .remap(fromLow: -100, fromHigh: 100, toLow: -0.15, toHigh: 0.15)
              .abs();

      /// Rotate the card based on the x-axis position
      double cardSwipeXRotation = value
          .clamp(-100.0, 100.0)
          .remap(fromLow: -100, fromHigh: 100, toLow: -0.2, toHigh: 0.2)
          .abs();

      return GestureDetector(
        onPanUpdate: (details) {
          /// Update the card position
          _springSimulation.springPosition += details.delta;
          // print(_springSimulation.springPosition.dx);
        },
        onPanEnd: (details) {
          if (value.abs() > 180) {
            /// Here, I want the top card to be moved to the back of the stacks,
            /// only after the spring simulation comes to rest
            /// should the next part of the code happen

            // _springSimulation.start();

            // if (_cardColors.isNotEmpty) {
            //   Color removedCard = _cardColors.removeAt(0);
            //   _cardColors.add(removedCard);
            // }
            _moveTopCardToBack();
            _springSimulation.start();
          } else {
            _springSimulation.start();
          }
        },
        onPanCancel: () {
          _springSimulation.start();
        },
        child: Transform(
          transform: Matrix4.identity()
            ..setTranslationRaw(value, 0, 0)
            ..setEntry(3, 2, perspective)
            ..scale(cardScaleFactor)
            ..rotateX(cardSwipeXRotation)
            ..rotateY(rotationAngle),
          alignment: Alignment.center,
          child: _buildCardContainer(_cardColors[index]),
        ),
      );
    }

    /// Second card
    if (index == 1) {
      double zRotation1 = clampedValue.abs().remap(
            fromLow: 0,
            fromHigh: maxOffset,
            toLow: -0.2,
            toHigh: 0,
          );

      return Transform(
        transform: Matrix4.identity()..rotateZ(zRotation1),
        alignment: Alignment.center,
        child: _buildCardContainer(
          _cardColors[index],
        ),
      );
    }

    if (index == 2) {
      double zRotation2 = clampedValue.abs().remap(
            fromLow: 0,
            fromHigh: maxOffset,
            toLow: 0.2,
            toHigh: 0,
          );

      return Transform(
        transform: Matrix4.identity()..rotateZ(zRotation2),
        alignment: Alignment.center,
        child: _buildCardContainer(
          _cardColors[index],
        ),
      );
    }

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
