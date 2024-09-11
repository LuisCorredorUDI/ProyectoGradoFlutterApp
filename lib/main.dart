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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Cambia aquí el color principal
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Puedes agregar más configuraciones de tema aquí
      ),
      //home: HomePage(),
      home: const ClaseLogin(),
    );
  }
}
//Vista principal fin