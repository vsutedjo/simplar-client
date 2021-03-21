import 'dart:ui';

class PainterTextLine extends SimpleTextLine {
  final Rect boundingBox;

  PainterTextLine(String text, this.boundingBox) : super(text);
}

class PlaintextEntryLine extends SimpleTextLine {
  final String assetName;
  PlaintextEntryLine(String text, this.assetName) : super(text);
}

class SimpleTextLine {
  final String text;
  SimpleTextLine(this.text);
}
