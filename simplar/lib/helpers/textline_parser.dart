import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:simplAR/models/simpleTextLine.dart';

List<PainterTextLine> generateTextLine(TextBlock block, List<String> content) {
  List<PainterTextLine> blockLines = [];
  for (int i = 0; i < block.lines.length; i++) {
    String simpleText = content[i % content.length];
    Rect boundingBox = block.lines[i].boundingBox;
    blockLines.add(PainterTextLine(simpleText, boundingBox));
  }
  return blockLines;
}
