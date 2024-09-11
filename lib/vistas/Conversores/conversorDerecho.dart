// To parse this JSON data, do
//
//     final conversorDerecho = conversorDerechoFromJson(jsonString);

import 'dart:convert';

List<ConversorDerecho> conversorDerechoFromJson(String str) =>
    List<ConversorDerecho>.from(
        json.decode(str).map((x) => ConversorDerecho.fromJson(x)));

String conversorDerechoToJson(List<ConversorDerecho> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversorDerecho {
  final int codigo;
  final String detalle;
  final int tipousuario;

  ConversorDerecho({
    required this.codigo,
    required this.detalle,
    required this.tipousuario,
  });

  factory ConversorDerecho.fromJson(Map<String, dynamic> json) =>
      ConversorDerecho(
        codigo: json["CODIGO"],
        detalle: json["DETALLE"],
        tipousuario: json["TIPOUSUARIO"],
      );

  Map<String, dynamic> toJson() => {
        "CODIGO": codigo,
        "DETALLE": detalle,
        "TIPOUSUARIO": tipousuario,
      };
}
