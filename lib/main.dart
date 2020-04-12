
import 'package:agendei/screens/open_screen.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'Agendei',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            primaryColor:  Color.fromARGB(255, 25,25,112),
          ),
          debugShowCheckedModeBanner: false,
          home: OpenScreen()

    );
  }
}