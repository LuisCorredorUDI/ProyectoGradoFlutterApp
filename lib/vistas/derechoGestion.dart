import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/globales.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorDerecho.dart';

class ClaseDerechoGestion extends StatefulWidget {
  // Variables
  final int modo; // 0 para crear, 1 para editar
  final String codigoDerecho;

  const ClaseDerechoGestion(this.modo, this.codigoDerecho, {super.key});

  @override
  State<StatefulWidget> createState() => _DerechoGestionState();
}

class _DerechoGestionState extends State<ClaseDerechoGestion> {
  // Variables
  TextEditingController _detalleController = TextEditingController();
  bool _cargando = false; // Indicador de carga

  // Procedimiento para cargar detalles si es edición
  Future<void> cargarDetalleDerecho() async {
    if (widget.modo == 1) {
      setState(() {
        _cargando = true;
      });

      try {
        final respuesta = await Dio().get(
          '${GlobalesClass.direccionApi}/derecho/detalle/${widget.codigoDerecho}',
        );

        if (respuesta.statusCode == 200) {
          List<dynamic> data = respuesta.data;
          if (data.isNotEmpty) {
            final derecho = ConversorDerecho.fromJson(data.first);
            setState(() {
              _detalleController.text = derecho.detalle; // Cargar el detalle
            });
          }
        }
      } catch (e) {
        print('Error al cargar el detalle del derecho: $e');
      } finally {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Función para guardar un nuevo derecho
  Future<void> guardarDerecho() async {
    try {
      setState(() {
        _cargando = true;
      });

      final respuesta = await Dio().post(
        '${GlobalesClass.direccionApi}/derecho/crear',
        data: {
          "DETALLE": _detalleController.text,
        },
      );

      if (respuesta.statusCode == 200) {
        _mostrarMensajeExito('Derecho Guardado');
        Navigator.pop(context, true); // Regresar con éxito
      }
    } catch (e) {
      _mostrarMensajeError('Error al guardar');
      print('Error al guardar el derecho: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  // Función para actualizar un derecho existente
  Future<void> actualizarDerecho() async {
    try {
      setState(() {
        _cargando = true;
      });

      final respuesta = await Dio().patch(
        '${GlobalesClass.direccionApi}/derecho/Actualizar',
        data: {
          "DETALLE": _detalleController.text,
          "CODIGO": widget.codigoDerecho.toString()
        },
      );

      if (respuesta.statusCode == 200) {
        _mostrarMensajeExito('Derecho Actualizado');
        Navigator.pop(context, true); // Regresar con éxito
      }
    } catch (e) {
      _mostrarMensajeError('Error al guardar');
      print('Error al actualizar el derecho: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  // Método para mostrar un mensaje de éxito
  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Método para mostrar un mensaje de error
  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    cargarDetalleDerecho();
  }

  // Vista principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modo == 0 ? "Crear Derecho" : "Editar Derecho"),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _detalleController,
                    decoration: const InputDecoration(
                      labelText: 'Detalle del Derecho',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 7,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_detalleController.text.isNotEmpty) {
                        if (widget.modo == 0) {
                          guardarDerecho();
                        } else {
                          actualizarDerecho();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El detalle no puede estar vacío'),
                          ),
                        );
                      }
                    },
                    child: Text("Guardar"),
                  ),
                ],
              ),
            ),
    );
  }
}
