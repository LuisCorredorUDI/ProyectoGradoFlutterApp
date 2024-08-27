import 'package:flutter/material.dart';

class ClasePQR extends StatelessWidget {
  //Variables
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;

  const ClasePQR(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pqr"),
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
