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

class MainApp extends StatelessWidget {
  final CameraDescription camera;

  const MainApp({Key key, this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SimplAR',
        theme: ThemeData(
          primarySwatch: kOrange,
          fontFamily: "Product-Sans",
        ),
        home: FutureBuilder(
            initialData: LoadingScreen(),
            future: Future.delayed(Duration(seconds: 2), () {
              return CameraScreen();
            }),
            builder: (context, snapshot) {
              return snapshot.data;
            }));
  }
}
