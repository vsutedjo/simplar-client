import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'helpers/text_detector_painter.dart';
import 'main.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<TextLine> textLines = [];
  String _imagePath;
  Size _imageSize;
  List<String> _simpleText;
  bool currShowingImage = false;
  @override
  void initState() {
    super.initState();
    initCameras();
  }

  void initCameras() async {
    _controller = CameraController(
      context.findAncestorWidgetOfExactType<MainApp>().camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyzeImage() async {
    var image = FirebaseVisionImage.fromFilePath(_imagePath);
    _getImageSize(File(_imagePath));
    TextRecognizer recognizeText = FirebaseVision.instance.cloudTextRecognizer();
    VisionText readText = await recognizeText.processImage(image);
    String wholeText = "";
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        textLines.add(line);

        // Text body
        if (line.text.endsWith("-")) {
          wholeText += line.text.substring(0, line.text.length - 1);
        } else {
          wholeText += line.text + " ";
        }
      }
    }
    print(wholeText);
    List<String> data = wholeText.split(RegExp(r"[:.]"))..removeWhere((s) => s == " ");
    print(data);
    setState(() {});

    http
        .post(Uri.parse("https://webhook.site/d493c654-cca6-4321-8e26-4aad70aa24b9"), body: jsonEncode({"data": data}))
        .then((result) {
      var simpleText = (jsonDecode(result.body)["data"] as List<dynamic>).map((i) => "$i").toList();
      print(simpleText);
      setState(() {
        _simpleText = simpleText;
      });
    });
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

  String _getTextDisplay() {
    var res = "";
    for (TextLine line in textLines) {
      res += line.text + "\n";
    }
    return res;
  }

  Widget cameraWidget(context) {
    var camera = _controller.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (currShowingImage)
                  Image.file(
                    File(_imagePath),
                    fit: BoxFit.fill,
                  )
                else
                  CameraPreview(_controller),
                if (_simpleText != null)
                  for (int i = 0; i < textLines.length; i++)
                    CustomPaint(
                        painter: TextDetectorPainter(_imageSize, textLines[i].elements, _simpleText[i],
                            showSimpleText: true))
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: currShowingImage && textLines.isEmpty
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            : Icon(currShowingImage ? Icons.camera_alt : Icons.translate),
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
              await _initializeControllerFuture;
              var img = await _controller.takePicture();
              setState(() {
                _imagePath = img.path;
                currShowingImage = true;
              });
              _analyzeImage();
            }
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
