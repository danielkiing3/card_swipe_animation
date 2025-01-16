import 'package:card_swipe_animation/helpers/remap.dart';
import 'package:card_swipe_animation/helpers/spring_simulation.dart';
import 'package:card_swipe_animation/widgets/card_widget.dart';
import 'package:flutter/material.dart';

final List<Color> cardColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  // Colors.yellow,
];

class CardSwipeTest extends StatefulWidget {
  const CardSwipeTest({super.key});

  @override
  State<CardSwipeTest> createState() => _CardSwipeTestState();
}

class _CardSwipeTestState extends State<CardSwipeTest>
    with SingleTickerProviderStateMixin {
  /// Spring simulation for the card swipe animation
  late final SpringSimulation2D _springSimulation;
  bool isDragging = false;

  int topCardIndex = 0;

  late List<Widget> testingStack;

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

    testingStack = [
      ListenableBuilder(
        listenable: _springSimulation,
        builder: (context, child) {
          return _buildCard(1, _springSimulation.springPosition.dx);
        },
      ),
      ListenableBuilder(
        listenable: _springSimulation,
        builder: (context, child) {
          return _buildCard(2, _springSimulation.springPosition.dx);
        },
      ),
      ListenableBuilder(
        listenable: _springSimulation,
        builder: (context, child) {
          return _buildCard(0, _springSimulation.springPosition.dx);
        },
      ),
    ];
  }

  @override
  void dispose() {
    _springSimulation.dispose();
    super.dispose();
  }

  void moveTopToBack() {
    setState(() {
      // Remove the last item and insert it at the beginning
      final topItem = testingStack.removeLast();
      testingStack.insert(0, topItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      // children: List.generate(_cardColors.length, (index) {
      //   return ListenableBuilder(
      //     listenable: _springSimulation,
      //     builder: (context, child) {
      //       return _buildCard(
      //           index, _springSimulation.springPosition.dx);
      //     },
      //   );
      // }).reversed.toList(),

      children: testingStack,
    );
  }

  void _moveTopCardToBack() {
    if (cardColors.isNotEmpty) {
      // Remove the top card
      Color removedCard = cardColors.removeAt(0);

      // Add it to the back of the stack
      cardColors.add(removedCard);
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
          if (value.abs() > 150) {
            moveTopToBack();
            _springSimulation.start();
            isDragging = true;
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
            // ..rotateX(cardSwipeXRotation)
            ..rotateY(rotationAngle),
          alignment: Alignment.center,
          child: CardWidget(color: cardColors[index]),
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
        child: CardWidget(color: cardColors[index]),
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
        child: CardWidget(color: cardColors[index]),
      );
    }

    return CardWidget(color: cardColors[index]);
  }
}
