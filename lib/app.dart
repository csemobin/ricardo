import 'package:flutter/material.dart';

class RideSharingApplication extends StatelessWidget{
  const RideSharingApplication({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('Maruf')),
      )
    );
  }
}