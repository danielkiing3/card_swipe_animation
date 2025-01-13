import 'package:flutter/material.dart';
import 'dart:math' as math;

class SwipeableCardStack extends StatefulWidget {
  final List<Widget> cards;
  final double threshold;

  const SwipeableCardStack({
    super.key,
    required this.cards,
    this.threshold = 0.3,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack>
    with TickerProviderStateMixin {
  late List<Widget> _cards;
  double _dragOffset = 0;
  bool _isAnimating = false;

  // Animation controllers
  late AnimationController _swipeController;
  late AnimationController _returnController;

  // Animations
  late Animation<double> _swipeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _returnPositionAnimation;
  late Animation<double> _returnRotationAnimation;
  late Animation<double> _returnScaleAnimation;
  late Animation<double> _returnElevationAnimation;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards);

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startReturnAnimation();
      }
    });

    _returnController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          final card = _cards.removeAt(0);
          _cards.add(card);
          _dragOffset = 0;
          _isAnimating = false;
          _swipeController.reset();
          _returnController.reset();
        });
      }
    });
  }

  void _startReturnAnimation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final startX = _dragOffset > 0 ? screenWidth : -screenWidth;

    // Create a curved path from swiped position to back of stack
    _returnPositionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(startX, 0),
          end: Offset(startX * 0.7, -100), // Move up and slightly back
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(startX * 0.7, -100),
          end: Offset(0, 40), // Move to back of stack
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 70.0,
      ),
    ]).animate(_returnController);

    // Rotation animation for card flipping
    _returnRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _dragOffset > 0 ? math.pi / 8 : -math.pi / 8,
          end: _dragOffset > 0 ? math.pi / 2 : -math.pi / 2,
        ),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _dragOffset > 0 ? math.pi / 2 : -math.pi / 2,
          end: 0.0,
        ),
        weight: 70.0,
      ),
    ]).animate(_returnController);

    // Scale animation
    _returnScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.9),
        weight: 70.0,
      ),
    ]).animate(_returnController);

    // Elevation animation to help with 3D effect
    _returnElevationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 40),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 40, end: 0),
        weight: 70.0,
      ),
    ]).animate(_returnController);

    _returnController.forward();
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * widget.threshold;

    if (_dragOffset.abs() > threshold) {
      _isAnimating = true;

      final endPosition = _dragOffset > 0 ? screenWidth : -screenWidth;
      _swipeAnimation = Tween<double>(
        begin: _dragOffset,
        end: endPosition,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOut,
      ));

      _rotationAnimation = Tween<double>(
        begin: _dragOffset / 1000,
        end: (_dragOffset > 0 ? 1 : -1) * math.pi / 8,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOut,
      ));

      _swipeController.forward();
    } else {
      // Spring back to center
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  Matrix4 _getCardTransform(int index, BuildContext context) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001); // Perspective transform

    if (index == 0) {
      double offsetX = _dragOffset;
      double offsetY = 0.0;
      double rotation = _dragOffset / 1000;
      double scale = 1.0;
      double elevationZ = 0.0;

      if (_swipeController.isAnimating) {
        offsetX = _swipeAnimation.value;
        rotation = _rotationAnimation.value;
      } else if (_returnController.isAnimating) {
        final returnOffset = _returnPositionAnimation.value;
        offsetX = returnOffset.dx;
        offsetY = returnOffset.dy;
        rotation = _returnRotationAnimation.value;
        scale = _returnScaleAnimation.value;
        elevationZ = _returnElevationAnimation.value;
      }

      return matrix
        ..translate(offsetX, offsetY, elevationZ)
        ..rotateZ(rotation)
        ..scale(scale);
    } else {
      // Transform for cards in the stack
      final scale = 1.0 - (0.05 * index);
      final yOffset = 20.0 * index;

      return matrix
        ..translate(0.0, yOffset, -10.0 * index)
        ..scale(scale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_swipeController, _returnController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(_cards.length, (index) {
            if (index >= 3) return const SizedBox.shrink();

            return Positioned(
              child: Transform(
                transform: _getCardTransform(index, context),
                alignment: Alignment.center,
                child: GestureDetector(
                  onHorizontalDragUpdate:
                      index == 0 ? _onHorizontalDragUpdate : null,
                  onHorizontalDragEnd: index == 0 ? _onHorizontalDragEnd : null,
                  child: _cards[index],
                ),
              ),
            );
          }).reversed.toList(),
        );
      },
    );
  }
}

// Example card widget remains the same
class ExampleCard extends StatelessWidget {
  final Color color;
  final String text;

  const ExampleCard({
    Key? key,
    required this.color,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
