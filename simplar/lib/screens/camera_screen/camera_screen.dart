import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simplAR/helpers/demo_texts.dart';
import 'package:simplAR/models/simpleTextLine.dart';
import 'package:simplAR/screens/plaintext_screen/plaintext_screen.dart';

import '../../helpers/text_detector_painter.dart';

class CameraScreen extends StatefulWidget {
  final CameraController controller;

  const CameraScreen(this.controller);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _imagePath;
  Size _imageSize;
  List<List<SimpleTextLine>> textLines = [];
  bool currShowingImage = false;
  bool showInAR = true;

  bool _isDemo = true;

  Future<void> _analyzeImage() async {
    var image = FirebaseVisionImage.fromFilePath(_imagePath);
    _getImageSize(File(_imagePath));
    TextRecognizer recognizeText = FirebaseVision.instance.cloudTextRecognizer();
    VisionText readText = await recognizeText.processImage(image);

    showInAR = true;
    if (_isDemo) {
      for (TextBlock block in readText.blocks) {
        textLines.add(getDemoText(block));
      }
    } else {
      http
          .post(Uri.parse("http://35.242.217.151:8080/"),
              body: jsonEncode({"data": readText.blocks.map((block) => block.text).toList(), "ai": "default"}))
          .then((result) {
        var simpleText = (jsonDecode(result.body)["data"] as List<dynamic>).map((i) => "$i").toList();
        print(simpleText);
      });
    }
    if (readText.blocks.any((e) => e.text.length > 200)) {
      showInAR = false;
    }
    setState(() {});
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  Widget cameraWidget(context) {
    var camera = widget.controller.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("SimplAR",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 30,
            )),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (currShowingImage)
              Image.file(
                File(_imagePath),
                fit: BoxFit.fill,
              )
            else
              CameraPreview(widget.controller),
            if (showInAR)
              for (var block in textLines)
                for (var line in block) CustomPaint(painter: TextDetectorPainter(_imageSize, line))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          child: currShowingImage && textLines.isEmpty
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              : Icon(currShowingImage ? Icons.close : Icons.camera, color: Colors.white),
          onPressed: () async {
            try {
              // If we come from the preview, go back to camera
              if (currShowingImage) {
                setState(() {
                  textLines = [];
                  currShowingImage = false;
                });
                // If we are in camera, take a picture and go to preview mode
              } else {
                setState(() {
                  textLines = [];
                });
                await widget.controller.setFlashMode(FlashMode.off);
                var img = await widget.controller.takePicture();
                setState(() {
                  _imagePath = img.path;
                  currShowingImage = true;
                });
                await _analyzeImage();
                if (!showInAR) {
                  assert(textLines.every((element) => element.runtimeType != PainterTextLine));
                  List<SimpleTextLine> lines = [];
                  for (var block in textLines) {
                    lines.addAll(block);
                  }
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => PlaintextScreen(lines)))
                      .whenComplete(() => setState(() {
                            currShowingImage = false;
                          }));
                }
              }
            } catch (e) {
              print(e);
            }
          },
        ),
      ),
    );
  }
}
