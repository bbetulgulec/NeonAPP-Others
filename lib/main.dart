import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:others/Animation.dart';
import 'package:others/Hives.dart';
import 'package:others/dio.dart';
import 'package:others/httpRequest.dart';
import 'package:others/restfulApi.dart';
import 'package:others/sqlLite.dart';

void main() async {
  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AnimationWidgetState(),
    );
  }
}
