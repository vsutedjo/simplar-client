import 'package:flutter/material.dart';
import 'package:simplAR/models/simpleTextLine.dart';
import 'package:simplAR/res/theme.dart';

class PlaintextScreen extends StatelessWidget {
  final List<PlaintextEntryLine> entries;

  const PlaintextScreen(this.entries);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(children: [
            ...entries
                .map((entry) =>
                    entry.imageUrl != "" ? PlaintextEntryWithImage(entry) : PlaintextEntryWithoutImage(entry))
                .toList(),
            ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kOrange)),
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK", style: TextStyle(color: Colors.white))),
          ]),
        ),
      ),
    );
  }
}

class PlaintextEntryWithoutImage extends StatelessWidget {
  final SimpleTextLine entry;

  const PlaintextEntryWithoutImage(this.entry);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(entry.text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
    );
  }
}

class PlaintextEntryWithImage extends StatelessWidget {
  final PlaintextEntryLine entry;

  const PlaintextEntryWithImage(this.entry);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image(
              image: NetworkImage(entry.imageUrl), //AssetImage("lib/assets/images/${entry.imageUrl}.png"),
              width: MediaQuery.of(context).size.width * 0.25,
            ),
          ),
          Flexible(child: Text(entry.text, style: TextStyle(fontSize: 20)))
        ],
      ),
    );
  }
}
