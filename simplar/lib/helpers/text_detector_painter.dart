import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements, this.simpleText, {this.showSimpleText = true});

  final Size absoluteImageSize;
  final List<TextElement> elements;
  final String simpleText;
  bool showSimpleText;
  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX - 1,
        container.boundingBox.top * scaleY - 1,
        container.boundingBox.right * scaleX + 1,
        container.boundingBox.bottom * scaleY + 1,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white70;

    if (showSimpleText) {
      // Draw the white box over the original text
      Rect wholeRect = Rect.fromPoints(scaleRect(elements.first).bottomLeft, scaleRect(elements.last).topRight);
      canvas.drawRect(wholeRect, paint);

      // To prevent differently scaled texts for a textline, calculate avg. size
      double avgHeight =
          elements.map((element) => scaleRect(element).height).toList().reduce((a, b) => a + b) / elements.length;

      // Draw the simple text line at the coordinate of the detected original line
      drawName(canvas, simpleText, avgHeight, wholeRect.left, wholeRect.top);
    } else {
      // Draw word for word
      for (TextElement element in elements) {
        canvas.drawRect(scaleRect(element), paint);
        drawName(canvas, element.text, scaleRect(element).height, scaleRect(element).left, scaleRect(element).top);
      }
    }
  }

  void rotate(Canvas canvas, double cx, double cy, double angle) {
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.translate(-cx, -cy);
  }

  void drawName(Canvas context, String text, double size, double x, double y) {
    TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: size,
        ),
        text: text);
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(context, Offset(x, y));
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}
