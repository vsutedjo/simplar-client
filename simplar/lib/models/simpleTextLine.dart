import 'dart:ui';

class PainterTextLine extends SimpleTextLine {
  final Rect boundingBox;

  PainterTextLine(String text, this.boundingBox) : super(text);
}

class PlaintextEntryLine extends SimpleTextLine {
  final String imageUrl;

  PlaintextEntryLine(String text, this.imageUrl) : super(text);

  PlaintextEntryLine.fromMap(Map<String, String> map)
      : imageUrl = map["imageUrl"],
        super.fromMap(map);
}

class SimpleTextLine {
  final String text;
  SimpleTextLine(this.text);

  SimpleTextLine.fromMap(Map<String, String> map) : text = map["text"];
}
