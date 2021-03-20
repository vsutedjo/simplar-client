import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: const AssetImage("lib/assets/logo.png"),
          height: MediaQuery.of(context).size.height * 0.4,
        ),
      ),
    );
  }
}
