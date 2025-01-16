import 'package:card_swipe_animation/helpers/helpers.dart';
import 'package:card_swipe_animation/helpers/spring_simulation.dart';
import 'package:card_swipe_animation/widgets/card_model.dart';
import 'package:card_swipe_animation/widgets/card_widget.dart';
import 'package:flutter/material.dart';

final List<CardModel> cardModelList = [
  const CardModel(color: Colors.green, id: 2, zIndex: 2),
  const CardModel(color: Colors.blue, id: 1, zIndex: 1),
  const CardModel(color: Colors.red, id: 0, zIndex: 0),
];

/// Maximum offset for card offset
const double kMaximumOffset = 200.0;

class CardSwipeStack extends StatefulWidget {
  const CardSwipeStack({super.key});

  @override
  State<CardSwipeStack> createState() => _CardSwipeStackState();
}

class _CardSwipeStackState extends State<CardSwipeStack>
    with SingleTickerProviderStateMixin {
  /// Spring based simulation for card motion
  late final SpringSimulation2D _springSimulation;

  /// List of widget to be displayed in the stack widget
  late List<Widget> _stackChildren;

  /// -- Testing
  int selectedIndex = 0;

  /// -- Testing

  @override
  void initState() {
    super.initState();

    /// Initialization of the Spring Simulation
    _springSimulation = SpringSimulation2D(
      tickerProvider: this,
      spring: const SpringDescription(mass: 20, stiffness: 10, damping: 1),
    );

    _stackChildren = List.generate(
      cardModelList.length,
      (index) {
        return ListenableBuilder(
          listenable: _springSimulation,
          builder: (context, child) {
            return _buildCard(
                cardModelList[index], _springSimulation.springPosition.dx);
          },
        );
      },
    );

    // _stackChildren = [];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: _stackChildren,
    );
  }

  void updateStackChildren() {
    setState(() {
      // Remove the front card (zIndex = 0) and move it to the back
      // final topItem = _stackChildren.removeLast();
      // _stackChildren.insert(0, topItem);

      final topCardModel = cardModelList.removeLast();
      cardModelList.insert(0, topCardModel);

      // Updating the zIndex of the card model list
      // for (int i = 0; i < cardModelList.length; i++) {
      //   cardModelList[i] = cardModelList[i].updateZIndex();
      // }

      // Updating the zIndex of the selected index to zero
      // cardModelList[selectedIndex] =
      //     cardModelList[selectedIndex].copyWith(zIndex: cardModelList.length);

      // // Updating the new selected index
      // selectedIndex = cardModelList
      //     // Obtaining the cardModel with [zIndex] eqauls to length of [cardModelList]
      //     .firstWhere((carModel) => carModel.zIndex == cardModelList.length)
      //     // Setting selectedIndex to the cardModel id
      //     .id;
    });
  }

  Widget _buildCard(CardModel item, double value) {
    /// Value for the rotation along the z-axis of the widget
    double zRotation;

    /// Scaling factor for the widgets
    double cardScaleFactor;

    double cardOffset;

    /// Setting the y-offset
    double yRotation;

    double clampedValue = value.clamp(-kMaximumOffset, kMaximumOffset);

    double perspective = 0.003;

    double rotationAngle = value / 200;

    int cardIndex = cardModelList.length - 1 - cardModelList.indexOf(item);

    print(
        'Card of id: ${item.id}   Current card index: $cardIndex  Color: ${ColorHelper.getColorName(item.color)} ');

    // Card is at the front
    if (cardIndex == 0) {
      // Set zRotation to zero
      zRotation = 0.0;

      // Setting cardScaleFactor
      cardScaleFactor = 1 -
          clampedValue
              .remap(fromLow: -100, fromHigh: 100, toLow: -0.15, toHigh: 0.15)
              .abs();

      // Setting card offset
      cardOffset = value;
    }
    // Card is a odd number
    else if (cardIndex % 2 == 1) {
      // Set zRotation to zero
      zRotation = clampedValue.abs().remap(
            fromLow: 0,
            fromHigh: kMaximumOffset,
            toLow: -0.3,
            toHigh: 0.1,
          );

      // Setting cardScaleFactor
      cardScaleFactor = 0.7 +
          clampedValue
              .abs()
              .remap(fromLow: 0, fromHigh: 100, toLow: 0.3, toHigh: 0.2);

      // Setting card offset
      cardOffset = 0;
    }
    // Card is an even number
    else {
      // Set zRotation to zero

      zRotation = clampedValue.abs().remap(
            fromLow: 0,
            fromHigh: kMaximumOffset,
            toLow: 0.3,
            toHigh: 0.1,
          );

      // Setting cardScaleFactor
      cardScaleFactor = 0.7 +
          clampedValue
              .abs()
              .remap(fromLow: 0, fromHigh: 100, toLow: 0.3, toHigh: 0.2);

      // Setting card offset
      cardOffset = 0;
    }

    return Positioned(
      key: ValueKey(item.id),
      child: GestureDetector(
        onPanUpdate: cardIndex != selectedIndex
            ? null
            : (details) {
                // Updating the spring position of the spring simulation
                _springSimulation.springPosition += details.delta;
              },
        onPanEnd: cardIndex != selectedIndex
            ? null
            : (details) {
                if (value.abs() > 150) {
                  updateStackChildren();
                }

                /// Start the spring simulation
                _springSimulation.start();
              },
        onPanCancel: cardIndex != selectedIndex
            ? null
            : () {
                // Starting the spring simulation
                _springSimulation.start();
              },
        child: Transform(
          transform: Matrix4.identity()
            // Setting the x offset translation
            ..setTranslationRaw(cardOffset, 0, 0)

            // Scaling
            ..scale(cardScaleFactor)

            // Setting rotation alone the z-axis
            ..rotateZ(zRotation)

            /// Setting the
            ..setEntry(3, 2, perspective)

          // Rotating alone the Y axis
          // ..rotateY(item.zIndex != 0 ? 0 : rotationAngle)
          ,
          alignment: Alignment.center,
          child: CardWidget(color: item.color),
        ),
      ),
    );
  }
}

class ColorHelper {
  static String getColorName(Color color) {
    if (color == Colors.green) {
      return 'Green';
    } else if (color == Colors.blue) {
      return 'Blue';
    } else {
      return 'Red';
    }
  }
}
