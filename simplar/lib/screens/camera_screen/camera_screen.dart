import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:simplAR/helpers/demo_texts.dart';
import 'package:simplAR/models/painterTextLine.dart';

import '../../helpers/text_detector_painter.dart';
import '../../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String _imagePath;
  Size _imageSize;
  List<List<PainterTextLine>> textLines = [];
  bool currShowingImage = false;

  bool _isDemo = true;
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

    if (_isDemo) {
      for (TextBlock block in readText.blocks) {
        if (block.text.contains("Workinstruction Section B4")) {
          List<PainterTextLine> blockLines = [];
          for (int i = 0; i < block.lines.length; i++) {
            String simpleText = workinstructionTitle[i % workinstructionTitle.length];
            Rect boundingBox = block.lines[i].boundingBox;
            blockLines.add(PainterTextLine(simpleText, boundingBox));
          }
          textLines.add(blockLines);
        } else if (block.text.contains("The M6 fine-thread")) {
          List<PainterTextLine> blockLines = [];
          for (int i = 0; i < block.lines.length; i++) {
            String simpleText = workinstructionText1[i % workinstructionText1.length];
            Rect boundingBox = block.lines[i].boundingBox;
            blockLines.add(PainterTextLine(simpleText, boundingBox));
          }
          textLines.add(blockLines);
        } else if (block.text.contains("It is to be ensured that the area")) {
          List<PainterTextLine> blockLines = [];
          for (int i = 0; i < block.lines.length; i++) {
            String simpleText = workinstructionText2[i % workinstructionText2.length];
            Rect boundingBox = block.lines[i].boundingBox;
            blockLines.add(PainterTextLine(simpleText, boundingBox));
          }
          textLines.add(blockLines);
        }
      }
      setState(() {});
    }
    /*else {
      String wholeText = "";
      for (TextBlock block in readText.blocks) {
        print("Text block: ${block.text}");
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
          .post(Uri.parse("https://webhook.site/d493c654-cca6-4321-8e26-4aad70aa24b9"),
              body: jsonEncode({"data": data}))
          .then((result) {
        var simpleText = (jsonDecode(result.body)["data"] as List<dynamic>).map((i) => "$i").toList();
        print(simpleText);
      });
    }*/
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
        child: FutureBuilder<void>(
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

                  for (var block in textLines)
                    for (var line in block)
                      CustomPaint(painter: TextDetectorPainter(_imageSize, line)) //!_showOriginalText))
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
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
                // await _initializeControllerFuture;
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
      ),
    );
  }
}
