// import 'package:card_swipe_animation/widgets/card_model.dart';
// import 'package:card_swipe_animation/widgets/card_widget.dart';
// import 'package:flutter/material.dart';

// const double kMaximumOffset = 200.0;

// final List<CardModel> cardModelList = [
//   const CardModel(color: Colors.green, id: 2, zIndex: 2),
//   const CardModel(color: Colors.blue, id: 1, zIndex: 1),
//   const CardModel(color: Colors.red, id: 0, zIndex: 0),
// ];

// class CardSwipeStackE extends StatefulWidget {
//   const CardSwipeStackE({super.key});

//   @override
//   State<CardSwipeStackE> createState() => _CardSwipeStackEState();
// }

// class _CardSwipeStackEState extends State<CardSwipeStackE> {
//   double swipeOffset = 0.0;

//   void updateStackChildren() {
//     setState(() {
//       // Move the top card to the back
//       final topCard = cardModelList.removeLast();
//       cardModelList.insert(0, topCard);

//       // Update zIndex values
//       for (int i = 0; i < cardModelList.length; i++) {
//         cardModelList[i] = cardModelList[i].copyWith(zIndex: i);
//       }

//       // Reset swipe offset
//       swipeOffset = 0.0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: cardModelList.map((card) {
//         return _buildCard(card);
//       }).toList(),
//     );
//   }

//   Widget _buildCard(CardModel item) {
//     double rotationAngle = swipeOffset / kMaximumOffset;
//     double scale = 1 - (item.zIndex * 0.1);

//     return Positioned(
//       child: GestureDetector(
//         onPanUpdate: (details) {
//           setState(() {
//             swipeOffset += details.delta.dx;
//           });
//         },
//         onPanEnd: (details) {
//           if (swipeOffset.abs() > 150) {
//             updateStackChildren();
//           } else {
//             setState(() {
//               swipeOffset = 0.0;
//             });
//           }
//         },
//         child: Transform(
//           transform: Matrix4.identity()
//             ..translate(swipeOffset, 0.0, 0.0)
//             ..scale(scale)
//             ..rotateZ(rotationAngle),
//           child: CardWidget(color: item.color),
//         ),
//       ),
//     );
//   }
// }
