import 'package:flutter/material.dart';
import 'package:campus_tour/view/welcome_page.dart';

void main(){
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("campus tour"),),
        body: WelcomePage(),
      )
    );
  }
}


