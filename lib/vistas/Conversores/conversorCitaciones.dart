// To parse this JSON data, do
//
//     final conversorCitacion = conversorCitacionFromJson(jsonString);

import 'dart:convert';

List<ConversorCitacion> conversorCitacionFromJson(String str) =>
    List<ConversorCitacion>.from(
        json.decode(str).map((x) => ConversorCitacion.fromJson(x)));

String conversorCitacionToJson(List<ConversorCitacion> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversorCitacion {
  final int codigo;
  final String detalle;
  final DateTime fechainicio;
  final DateTime fechafin;
  final int usuariocitacion;
  final String nombrecitado;
  final int citacionesnum;

  ConversorCitacion({
    required this.codigo,
    required this.detalle,
    required this.fechainicio,
    required this.fechafin,
    required this.usuariocitacion,
    required this.nombrecitado,
    required this.citacionesnum,
  });

  factory ConversorCitacion.fromJson(Map<String, dynamic> json) =>
      ConversorCitacion(
        codigo: json["CODIGO"],
        detalle: json["DETALLE"],
        fechainicio: DateTime.parse(json["FECHAINICIO"]),
        fechafin: DateTime.parse(json["FECHAFIN"]),
        usuariocitacion: json["USUARIOCITACION"],
        nombrecitado: json["NOMBRECITADO"],
        citacionesnum: json["CITACIONESNUM"],
      );

  Map<String, dynamic> toJson() => {
        "CODIGO": codigo,
        "DETALLE": detalle,
        "FECHAINICIO": fechainicio.toIso8601String(),
        "FECHAFIN": fechafin.toIso8601String(),
        "USUARIOCITACION": usuariocitacion,
        "NOMBRECITADO": nombrecitado,
        "CITACIONESNUM": citacionesnum,
      };
}
