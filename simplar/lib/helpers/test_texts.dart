import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:simplAR/helpers/textline_parser.dart';
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

PlaintextEntryLine getPlainDemoText(TextBlock block) {
  if (block.text.contains("Subject: Exterior facade cleaning")) {
    return PlaintextEntryLine(tenantTitle.join(), "");
  } else if (block.text.contains("In order to comply")) {
    return PlaintextEntryLine(tenantText.join(), "");
  }
}

List<PainterTextLine> getARDemoText(TextBlock block) {
  if (block.text.contains("Workinstruction Section B4")) {
    return generateTextLine(block, workinstructionTitle);
  } else if (block.text.contains("The M6 fine-thread")) {
    return generateTextLine(block, workinstructionText1);
  } else if (block.text.contains("It is to be ensured that the area")) {
    return generateTextLine(block, workinstructionText2);
  }
  return [];
}
