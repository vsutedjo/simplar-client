import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:simplAR/screens/camera_screen/camera_screen.dart';
import 'package:simplAR/screens/loading_screen/loading_screen.dart';

import 'res/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final frontCamera = cameras.first;

  runApp(MainApp(camera: frontCamera));
}

class MainApp extends StatefulWidget {
  final CameraDescription camera;
  const MainApp({Key key, this.camera}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  void initCameras() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.setFlashMode(FlashMode.off);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    super.initState();
    initCameras();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimplAR',
      theme: ThemeData(
        primarySwatch: kOrange,
        fontFamily: "Product-Sans",
      ),
      home: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraScreen(_controller);
            } else
              return LoadingScreen();
          }),
    );
  }
}
