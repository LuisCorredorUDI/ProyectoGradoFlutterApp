import 'package:flutter/material.dart';

class ClaseCitaciones extends StatelessWidget {
  //Variables
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;

  const ClaseCitaciones(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Citaciones"),
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
