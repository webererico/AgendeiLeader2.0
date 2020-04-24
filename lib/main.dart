import 'package:agendei/screens/open_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Color hexToColor() => new Color.fromARGB(255, 15, 76, 129);
    return MaterialApp(
        color: Color.fromARGB(255, 15, 76, 129),
        title: 'Agendei',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: hexToColor(),
          accentColor: hexToColor(),
          splashColor: hexToColor(),
        ),
        debugShowCheckedModeBanner: false,
        home: OpenScreen());
  }
}
