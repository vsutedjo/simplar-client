import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simplAR/helpers/test_texts.dart';
import 'package:simplAR/helpers/text_detector_painter.dart';
import 'package:simplAR/models/simpleTextLine.dart';
import 'package:simplAR/screens/plaintext_screen/plaintext_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraController controller;

  const CameraScreen(this.controller);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _imagePath;
  Size _imageSize;
  List<List<SimpleTextLine>> ARTextLines = [];
  List<PlaintextEntryLine> plainTextLines = [];
  bool currShowingImage = false;
  bool showInAR = true;

  bool _isTestRun = false;

  Future<void> _analyzeImage() async {
    var image = FirebaseVisionImage.fromFilePath(_imagePath);
    _getImageSize(File(_imagePath));
    TextRecognizer recognizeText = FirebaseVision.instance.cloudTextRecognizer();
    VisionText readText = await recognizeText.processImage(image);

    showInAR = true;
    if (_isTestRun) {
      if (readText.blocks.any((e) => e.text.length > 200)) {
        showInAR = false;
      }
      for (TextBlock block in readText.blocks) {
        if (showInAR)
          ARTextLines.add(getARDemoText(block));
        else
          plainTextLines.add(getPlainDemoText(block));
      }
    } else {
      var list = readText.blocks.map((block) => block.text).toList();
      var json = jsonEncode({"data": list, "useGPT3": false, "enableSummarizer": false});
      Uri uri = Uri.http("35.242.202.87:8080", "");
      final response = await http.post(uri,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json);
      if (response.statusCode == 200) {
        // Don't show in AR when coming from server
        showInAR = false;
        print(response.body);
        var responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        var entries = responseJson["data"] as List<Map<String, String>>;
        plainTextLines = entries.map((entry) => PlaintextEntryLine.fromMap(entry)).toList();
      } else {
        throw Exception(response.toString());
      }
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
              for (var block in ARTextLines)
                for (var line in block) CustomPaint(painter: TextDetectorPainter(_imageSize, line))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          child: currShowingImage && ARTextLines.isEmpty
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              : Icon(currShowingImage ? Icons.close : Icons.camera, color: Colors.white),
          onPressed: () async {
            try {
              // If we come from the preview, go back to camera
              if (currShowingImage) {
                setState(() {
                  ARTextLines = [];
                  currShowingImage = false;
                });
                // If we are in camera, take a picture and go to preview mode
              } else {
                setState(() {
                  ARTextLines = [];
                  plainTextLines = [];
                });
                await widget.controller.setFlashMode(FlashMode.off);
                var img = await widget.controller.takePicture();
                setState(() {
                  _imagePath = img.path;
                  currShowingImage = true;
                });
                await _analyzeImage();

                // If we want to show a new screen mit images
                if (!showInAR) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => PlaintextScreen(plainTextLines)))
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
