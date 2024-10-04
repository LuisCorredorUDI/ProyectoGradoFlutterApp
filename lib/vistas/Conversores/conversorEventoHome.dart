// To parse this JSON data, do
//
//     final conversorEventoHome = conversorEventoHomeFromJson(jsonString);

import 'dart:convert';

List<ConversorEventoHome> conversorEventoHomeFromJson(String str) =>
    List<ConversorEventoHome>.from(
        json.decode(str).map((x) => ConversorEventoHome.fromJson(x)));

String conversorEventoHomeToJson(List<ConversorEventoHome> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversorEventoHome {
  final int codigo;
  final String nombre;
  final String detalle;
  final DateTime fechainicio;
  final DateTime fechafin;
  final int idusuariocreacion;
  final String rutaimagen;
  final String imagenarchivo;

  ConversorEventoHome({
    required this.codigo,
    required this.nombre,
    required this.detalle,
    required this.fechainicio,
    required this.fechafin,
    required this.idusuariocreacion,
    required this.rutaimagen,
    required this.imagenarchivo,
  });

  factory ConversorEventoHome.fromJson(Map<String, dynamic> json) =>
      ConversorEventoHome(
        codigo: json["CODIGO"],
        nombre: json["NOMBRE"],
        detalle: json["DETALLE"],
        fechainicio: DateTime.parse(json["FECHAINICIO"]),
        fechafin: DateTime.parse(json["FECHAFIN"]),
        idusuariocreacion: json["IDUSUARIOCREACION"],
        rutaimagen: json["RUTAIMAGEN"],
        imagenarchivo: json["IMAGENARCHIVO"],
      );

  Map<String, dynamic> toJson() => {
        "CODIGO": codigo,
        "NOMBRE": nombre,
        "DETALLE": detalle,
        "FECHAINICIO": fechainicio.toIso8601String(),
        "FECHAFIN": fechafin.toIso8601String(),
        "IDUSUARIOCREACION": idusuariocreacion,
        "RUTAIMAGEN": rutaimagen,
        "IMAGENARCHIVO": imagenarchivo,
      };
}
