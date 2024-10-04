// To parse this JSON data, do
//
//     final conversorEventoGestion = conversorEventoGestionFromJson(jsonString);

import 'dart:convert';

List<ConversorEventoGestion> conversorEventoGestionFromJson(String str) =>
    List<ConversorEventoGestion>.from(
        json.decode(str).map((x) => ConversorEventoGestion.fromJson(x)));

String conversorEventoGestionToJson(List<ConversorEventoGestion> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversorEventoGestion {
  final int codigo;
  final String nombre;
  final DateTime fechainicio;

  ConversorEventoGestion({
    required this.codigo,
    required this.nombre,
    required this.fechainicio,
  });

  factory ConversorEventoGestion.fromJson(Map<String, dynamic> json) =>
      ConversorEventoGestion(
        codigo: json["CODIGO"],
        nombre: json["NOMBRE"],
        fechainicio: DateTime.parse(json["FECHAINICIO"]),
      );

  Map<String, dynamic> toJson() => {
        "CODIGO": codigo,
        "NOMBRE": nombre,
        "FECHAINICIO": fechainicio.toIso8601String(),
      };
}
