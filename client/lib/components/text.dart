import 'package:flutter/material.dart';

class ScrollingText extends StatelessWidget {
  const ScrollingText(
    this.text, {
    super.key,
    this.padding,
    this.width,
    this.style,
    this.textAlign,
  });

  final String text;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: AutoScrollController(text.length),
        // reverse: true,
        child: Text(
          text,
          maxLines: 1,
          style: style,
          textAlign: textAlign,
        ),
      ),
    );
  }
}

class AutoScrollController extends ScrollController {
  final int textSize;

  AutoScrollController(
    this.textSize, {
    super.initialScrollOffset,
    Duration? speed,
    Curve? curve,
  }) {
    speed ??= calculateSpeed();
    curve ??= Curves.linear;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      animateTo(
        position.maxScrollExtent,
        duration: speed!,
        curve: curve!,
      );
    });

    addListener(() {
      if (position.pixels >= position.maxScrollExtent - 0.5) {
        animateTo(
          position.minScrollExtent,
          duration: speed!,
          curve: curve!,
        );
      }
      if (position.pixels <= position.minScrollExtent + 0.5) {
        animateTo(
          position.maxScrollExtent,
          duration: speed!,
          curve: curve!,
        );
      }
    });
  }

  Duration calculateSpeed() {
    if (textSize < 30) return const Duration(milliseconds: 2500);
    return const Duration(seconds: 5);
  }
}
