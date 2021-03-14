import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final frontCamera = cameras.first;

  runApp(MainApp(camera: frontCamera));
}

class MainApp extends StatelessWidget {
  final CameraDescription camera;

  const MainApp({Key key, this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimplificAR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(title: 'SimplificAR'),
    );
  }
}
