import 'package:flutter/material.dart';
import 'package:simplAR/models/painterTextLine.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.textLine);

  final Size absoluteImageSize;
  final PainterTextLine textLine;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(Rect boundingBox) {
      return Rect.fromLTRB(
        boundingBox.left * scaleX - 1,
        boundingBox.top * scaleY - 1,
        boundingBox.right * scaleX + 1,
        boundingBox.bottom * scaleY + 1,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.9);

    // Draw the white box over the original text
    Rect wholeRect =
        Rect.fromPoints(scaleRect(textLine.boundingBox).bottomLeft, scaleRect(textLine.boundingBox).topRight);
    canvas.drawRect(wholeRect, paint);

    // Draw the simple text line at the coordinate of the detected original line
    drawName(canvas, textLine.text, scaleRect(textLine.boundingBox).height, wholeRect.left, wholeRect.top);
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
