import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
        child: Stack(
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
      ),
    );
  }

  Widget _buildCard(int index, double swipeOffset) {
    double staggeredOffset = index * 10.0;
    double scaleFactor = 1 - (index * 0.05);
    double interactiveOffset = swipeOffset * (0.1 * index);

    if (index == 0) {
      // Front card (swipeable)
      return GestureDetector(
        onPanUpdate: (details) {
          _swipeOffset.value += details.delta.dx;
        },
        onPanEnd: (details) {
          if (_swipeOffset.value.abs() > 150) {
            _moveCardToBack();
          } else {
            _animateCardBack();
          }
        },
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_swipeOffset.value, 0, 0)
            ..rotateZ(_swipeOffset.value / 500),
          alignment: Alignment.center,
          child: _buildCardContainer(_cardColors[index]),
        ),
      );
    }

    // Cards behind the front card (reactive)
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: swipeOffset, end: swipeOffset),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(interactiveOffset, staggeredOffset),
          child: Transform.scale(
            scale: scaleFactor,
            child: _buildCardContainer(_cardColors[index]),
          ),
        );
      },
    );
  }

  /// Move the front card to the back of the stack.
  void _moveCardToBack() {
    setState(() {
      _swipeOffset.value = 0;
      if (_cardColors.isNotEmpty) {
        Color removedCard = _cardColors.removeAt(0);
        _cardColors.add(removedCard);
      }
    });
  }

  /// Animates the front card back to its original position.
  void _animateCardBack() {
    _swipeOffset.value = 0;
  }

  /// Builds a card container with a given color.
  Widget _buildCardContainer(Color color) {
    return Container(
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
      ),
    );
  }
}
