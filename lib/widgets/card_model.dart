import 'dart:ui';

class CardModel {
  /// Colors of the card
  final Color color;
  final int id;
  final int zIndex;

  const CardModel({
    required this.id,
    required this.color,
    required this.zIndex,
  });

  /// Updates the `zIndex` by 1
  CardModel updateZIndex() {
    return copyWith(zIndex: zIndex - 1);
  }

  /// Allows copying with optional updates
  CardModel copyWith({
    Color? color,
    int? id,
    int? zIndex,
  }) {
    return CardModel(
      id: id ?? this.id,
      color: color ?? this.color,
      zIndex: zIndex ?? this.zIndex,
    );
  }
}
