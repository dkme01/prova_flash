import 'package:flutter/material.dart';
import 'package:prova_flash/pages/home/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Prova Flash Courier Flutter',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
        debugShowCheckedModeBanner: false);
  }
}
