import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/login.dart';

void main() {
  runApp(const MainApp());
}

//Vista principal inicio
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: HomePage(),
      home: ClaseLogin(),
    );
  }
}
//Vista principal fin