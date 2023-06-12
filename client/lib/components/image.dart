import 'package:flutter/material.dart';

class SquareImage extends StatelessWidget {
  const SquareImage(this.image, this.size, {super.key});

  final ImageProvider image;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      height: size,
      width: size,
      fit: BoxFit.fill,
    );
  }
}
