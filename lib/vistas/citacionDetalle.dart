import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/globales.dart';

class ClaseCitacionDetalle extends StatefulWidget {
  final int idCitacion;
  final int observaciones;
  // 1 - coor, 2 - acu, 3 - est
  final String tipoUsuarioSesion;

  const ClaseCitacionDetalle(
      this.idCitacion, this.observaciones, this.tipoUsuarioSesion,
      {super.key});

  @override
  _CitacionDetalleState createState() => _CitacionDetalleState();
}

class _CitacionDetalleState extends State<ClaseCitacionDetalle> {
  final TextEditingController _detalleController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _usuarioCitado;
  String? _usuarioObservacion;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _detalleDisciplinarioController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatosIniciales();
  }

  //FUNCION DE CARGUE DE DATOS, EN CASO DE CONSULTA.
  Future<void> cargarDatosIniciales() async {
    if (widget.observaciones > 0) {
      final respuesta = await Dio().get(
          '${GlobalesClass.direccionApi}/citacion/DetalleCitacionObservacion/${widget.idCitacion}');
      if (respuesta.statusCode == 200) {
        // Como la respuesta es una lista, accedemos al primer elemento de la lista
        final data =
            respuesta.data[0]; // Acceder al primer elemento de la lista
        setState(() {
          _detalleController.text = data['DETALLE'].toString();
          _fechaInicio = DateTime.parse(data['FECHAINICIO'].toString());
          _fechaFin = DateTime.parse(data['FECHAFIN'].toString());
          _usuarioCitado = data['NOMBRECITADO'].toString();
          //Observacion
          _tituloController.text = data['TITULO'].toString();
          _detalleDisciplinarioController.text =
              data['DETALLEOBSERVACION'].toString();
          _usuarioObservacion = data['NOMBREOBSERVACION'].toString();
        });
      }
    } else {
      final respuesta = await Dio().get(
          '${GlobalesClass.direccionApi}/citacion/DetalleCitacion/${widget.idCitacion}');
      if (respuesta.statusCode == 200) {
        // En este caso también accedemos al primer elemento de la lista
        final data =
            respuesta.data[0]; // Acceder al primer elemento de la lista
        setState(() {
          _detalleController.text = data['DETALLE'].toString();
          _fechaInicio = DateTime.parse(data['FECHAINICIO'].toString());
          _fechaFin = DateTime.parse(data['FECHAFIN'].toString());
          _usuarioCitado = data['NOMBRECITADO'].toString();
          //Observacion
          _tituloController.text = '-';
          _detalleDisciplinarioController.text = '-';
          _usuarioObservacion = '-';
        });
      }
    }
  }

  String _formatearFechaHora(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.year}/${fecha.month.toString().padLeft(2, '0')}/${fecha.day.toString().padLeft(2, '0')} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citación"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              Text(
                'Acudiente: $_usuarioCitado',
                style: TextStyle(color: Colors.blue[700]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detalleController,
                readOnly: true,
                maxLines: 3,
                maxLength: 250,
                cursorColor: Colors.blue,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Detalle',
                  labelStyle: TextStyle(color: Colors.blue),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildDateField(
                  "Fecha de Inicio", _formatearFechaHora(_fechaInicio)),
              const SizedBox(height: 16),
              _buildDateField("Fecha de Fin", _formatearFechaHora(_fechaFin)),
              const SizedBox(height: 16),
              if (widget.observaciones > 0) ...[
                Text(
                  'Observaciones disciplinarias',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Text(
                  'Observación al estudiante : $_usuarioObservacion',
                  style: TextStyle(color: Colors.blue[700]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tituloController,
                  readOnly: true,
                  maxLength: 100,
                  cursorColor: Colors.blue,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: Colors.blue),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detalleDisciplinarioController,
                  readOnly: true,
                  maxLines: 4,
                  maxLength: 500,
                  cursorColor: Colors.blue,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Detalle',
                    labelStyle: TextStyle(color: Colors.blue),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  //fin vista principal

  // Widget para mostrar fechas
  Widget _buildDateField(String label, String date) {
    return TextFormField(
      readOnly: true,
      cursorColor: Colors.blue,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.blue),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        border: const OutlineInputBorder(),
        hintText: date.isEmpty ? 'Seleccione una fecha' : date,
      ),
    );
  }

//fin state
}
