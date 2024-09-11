// To parse this JSON data, do
//
//     final conversorPqr = conversorPqrFromJson(jsonString);

import 'dart:convert';

List<ConversorPqr> conversorPqrFromJson(String str) => List<ConversorPqr>.from(
    json.decode(str).map((x) => ConversorPqr.fromJson(x)));

String conversorPqrToJson(List<ConversorPqr> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversorPqr {
  final int codigo;
  final String detalle;
  final dynamic respuesta;
  final int tipopqr;
  final int usuariogenera;
  final DateTime fechacreacion;
  final dynamic fecharespuesta;
  final int estadopqr;
  final int codigoderecho;
  final int numeroreferencia;
  final String nombretipopqr;
  final String nombreGravedadtipopqr;

  ConversorPqr({
    required this.codigo,
    required this.detalle,
    required this.respuesta,
    required this.tipopqr,
    required this.usuariogenera,
    required this.fechacreacion,
    required this.fecharespuesta,
    required this.estadopqr,
    required this.codigoderecho,
    required this.numeroreferencia,
    required this.nombretipopqr,
    required this.nombreGravedadtipopqr,
  });

  factory ConversorPqr.fromJson(Map<String, dynamic> json) => ConversorPqr(
        codigo: json["CODIGO"],
        detalle: json["DETALLE"],
        respuesta: json["RESPUESTA"],
        tipopqr: json["TIPOPQR"],
        usuariogenera: json["USUARIOGENERA"],
        fechacreacion: DateTime.parse(json["FECHACREACION"]),
        fecharespuesta: json["FECHARESPUESTA"],
        estadopqr: json["ESTADOPQR"],
        codigoderecho: json["CODIGODERECHO"],
        numeroreferencia: json["NUMEROREFERENCIA"],
        nombretipopqr: json["NOMBRETIPOPQR"],
        nombreGravedadtipopqr: json["NOMBRE_GRAVEDADTIPOPQR"],
      );

  Map<String, dynamic> toJson() => {
        "CODIGO": codigo,
        "DETALLE": detalle,
        "RESPUESTA": respuesta,
        "TIPOPQR": tipopqr,
        "USUARIOGENERA": usuariogenera,
        "FECHACREACION": fechacreacion.toIso8601String(),
        "FECHARESPUESTA": fecharespuesta,
        "ESTADOPQR": estadopqr,
        "CODIGODERECHO": codigoderecho,
        "NUMEROREFERENCIA": numeroreferencia,
        "NOMBRETIPOPQR": nombretipopqr,
        "NOMBRE_GRAVEDADTIPOPQR": nombreGravedadtipopqr,
      };
}
