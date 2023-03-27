import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pipeline/flutter_pipeline.dart';

void main() {
  final pipeline = FlutterPipeline.i;

  pipeline.enableFCRLogging(
    host: "<run frc server>",
    port: 9843,
    code: "<run frc server>",
    recordCrashes: kReleaseMode,
  );
  pipeline.run(() => runApp(const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
