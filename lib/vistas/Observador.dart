import 'package:flutter/material.dart';

class ClaseObservador extends StatelessWidget {
  //Variables
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;

  const ClaseObservador(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Observador"),
      ),
      body: Column(
        children: [
          Text("Id: $idUsuarioSesion"),
          Text("Nombre: $nombreUsuarioSesion"),
          Text("Tipo: $tipoUsuarioSesion")
        ],
      ),
    );
  }
}
