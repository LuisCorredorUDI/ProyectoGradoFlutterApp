// To parse this JSON data, do
//
//     final conversorUsuario = conversorUsuarioFromJson(jsonString);

import 'dart:convert';

List<ConversorUsuario> conversorUsuarioFromJson(String str) =>
    List<ConversorUsuario>.from(
        json.decode(str).map((x) => ConversorUsuario.fromJson(x)));

String conversorUsuarioToJson(List<ConversorUsuario> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversorUsuario {
  final int id;
  final String nombres;
  final String apellidos;
  final int documento;
  final String claveingreso;
  final String fechanacimiento;
  final int? numerotelefono;
  final int numeromovil;
  final String? correo;
  final String? direccion;
  final int estado;
  final int codigotipousuario;

  ConversorUsuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.documento,
    required this.claveingreso,
    required this.fechanacimiento,
    required this.numerotelefono,
    required this.numeromovil,
    required this.correo,
    required this.direccion,
    required this.estado,
    required this.codigotipousuario,
  });

  factory ConversorUsuario.fromJson(Map<String, dynamic> json) =>
      ConversorUsuario(
        id: json["ID"],
        nombres: json["NOMBRES"],
        apellidos: json["APELLIDOS"],
        documento: json["DOCUMENTO"],
        claveingreso: json["CLAVEINGRESO"],
        fechanacimiento: json["FECHANACIMIENTO"],
        numerotelefono: json["NUMEROTELEFONO"],
        numeromovil: json["NUMEROMOVIL"],
        correo: json["CORREO"],
        direccion: json["DIRECCION"],
        estado: json["ESTADO"],
        codigotipousuario: json["CODIGOTIPOUSUARIO"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "NOMBRES": nombres,
        "APELLIDOS": apellidos,
        "DOCUMENTO": documento,
        "CLAVEINGRESO": claveingreso,
        "FECHANACIMIENTO": fechanacimiento,
        "NUMEROTELEFONO": numerotelefono,
        "NUMEROMOVIL": numeromovil,
        "CORREO": correo,
        "DIRECCION": direccion,
        "ESTADO": estado,
        "CODIGOTIPOUSUARIO": codigotipousuario,
      };
}
