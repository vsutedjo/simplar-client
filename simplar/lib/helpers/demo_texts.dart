import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:simplAR/models/simpleTextLine.dart';

List<String> workinstructionTitle = ["Workinstruction Section B4"];
List<String> workinstructionText1 = [
  "Take the M6 screw. Ask your chief to watch.",
  "Search for the spot with a red arrow. Put the",
  "screw there."
];

List<String> workinstructionText2 = ["Look at the area around the spot.", "Do not damage this area."];

List<String> tenantTitle = ["Topic: Cleaning of the front wall"];
List<String> tenantText = [
  "There is a law from the city: Front walls must look clean. So, we must clean our front wall.",
  "A cleaning team will clean our wall.",
  "This costs money: 80 Euros for everyone.",
  "Please pay 80 Euros to us. Pay before the 31st of March."
];
List<String> tenantAssetPaths = ["judge", "cleaner", "money", "calendar"];

List<SimpleTextLine> getDemoText(TextBlock block) {
  if (block.text.contains("Workinstruction Section B4")) {
    return _generateTextLine(block, workinstructionTitle);
  } else if (block.text.contains("The M6 fine-thread")) {
    return _generateTextLine(block, workinstructionText1);
  } else if (block.text.contains("It is to be ensured that the area")) {
    return _generateTextLine(block, workinstructionText2);
  } else if (block.text.contains("Subject: Exterior facade cleaning")) {
    return tenantTitle.map((s) => SimpleTextLine(s)).toList();
  } else if (block.text.contains("In order to comply")) {
    return _generatePlaintextEntry(tenantText, tenantAssetPaths);
  }
  return [];
}

List<PainterTextLine> _generateTextLine(TextBlock block, List<String> content) {
  List<PainterTextLine> blockLines = [];
  for (int i = 0; i < block.lines.length; i++) {
    String simpleText = content[i % content.length];
    Rect boundingBox = block.lines[i].boundingBox;
    blockLines.add(PainterTextLine(simpleText, boundingBox));
  }
  return blockLines;
}

List<PlaintextEntryLine> _generatePlaintextEntry(List<String> content, List<String> assetPaths) {
  List<PlaintextEntryLine> blockLines = [];
  for (int i = 0; i < content.length; i++) {
    blockLines.add(PlaintextEntryLine(content[i], assetPaths[i]));
  }
  return blockLines;
}
