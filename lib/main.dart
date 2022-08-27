import 'package:flutter/material.dart';
import 'package:thingsboard_app/screens/init_screen.dart';
import 'package:provider/provider.dart';

import 'models/thingsboard_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThingsBoardProvider(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const InitScreen(),
      ),
    );
  }
}