import 'package:flutter/material.dart';

class SquareImage extends StatelessWidget {
  const SquareImage(
    this.image,
    this.size, {
    super.key,
    this.isLoading = false,
  });

  final ImageProvider image;
  final double size;
  final bool isLoading;

  Widget img() {
    return Image(
      image: image,
      height: size,
      width: size,
      fit: BoxFit.fitWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Stack(
        children: [
          img(),
          Container(
            alignment: Alignment.center,
            height: size,
            width: size,
            child: const CircularProgressIndicator(color: Color(0xFF837AFA)),
          ),
        ],
      );
    }
    return img();
  }
}
