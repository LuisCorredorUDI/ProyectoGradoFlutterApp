// To parse this JSON data, do
//
//     final conversorDeber = conversorDeberFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<ConversorDeber> conversorDeberFromJson(String str) =>
    List<ConversorDeber>.from(
        json.decode(str).map((x) => ConversorDeber.fromJson(x)));

String conversorDeberToJson(List<ConversorDeber> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversorDeber {
  final int codigo;
  final String detalle;

  ConversorDeber({
    required this.codigo,
    required this.detalle,
  });

  factory ConversorDeber.fromJson(Map<String, dynamic> json) => ConversorDeber(
        codigo: json["CODIGO"],
        detalle: json["DETALLE"],
      );

  Map<String, dynamic> toJson() => {
        "CODIGO": codigo,
        "DETALLE": detalle,
      };
}
