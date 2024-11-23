import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/globales.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorDeber.dart';

class ClaseDeberGestion extends StatefulWidget {
  // Variables
  final int modo; // 0 para crear, 1 para editar
  final String codigoDeber;

  const ClaseDeberGestion(this.modo, this.codigoDeber, {super.key});

  @override
  State<StatefulWidget> createState() => _DeberGestionState();
}

class _DeberGestionState extends State<ClaseDeberGestion> {
  // Variables
  TextEditingController _detalleController = TextEditingController();
  bool _cargando = false; // Indicador de carga

  // Procedimiento para cargar detalles si es edición
  Future<void> cargarDetalleDeber() async {
    if (widget.modo == 1) {
      setState(() {
        _cargando = true;
      });

      try {
        final respuesta = await Dio().get(
          '${GlobalesClass.direccionApi}/deber/detalle/${widget.codigoDeber}',
        );

        if (respuesta.statusCode == 200) {
          List<dynamic> data = respuesta.data;
          if (data.isNotEmpty) {
            final Deber = ConversorDeber.fromJson(data.first);
            setState(() {
              _detalleController.text = Deber.detalle; // Cargar el detalle
            });
          }
        }
      } catch (e) {
        print('Error al cargar el detalle del Deber: $e');
      } finally {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Función para guardar un nuevo Deber
  Future<void> guardarDeber() async {
    try {
      setState(() {
        _cargando = true;
      });

      final respuesta = await Dio().post(
        '${GlobalesClass.direccionApi}/deber/crear',
        data: {
          "DETALLE": _detalleController.text,
        },
      );

      if (respuesta.statusCode == 200) {
        _mostrarMensajeExito('Deber Guardado');
        Navigator.pop(context, true); // Regresar con éxito
      }
    } catch (e) {
      _mostrarMensajeError('Error al guardar');
      print('Error al guardar el Deber: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  // Función para actualizar un Deber existente
  Future<void> actualizarDeber() async {
    try {
      setState(() {
        _cargando = true;
      });

      final respuesta = await Dio().patch(
        '${GlobalesClass.direccionApi}/deber/Actualizar',
        data: {
          "DETALLE": _detalleController.text,
          "CODIGO": widget.codigoDeber.toString()
        },
      );

      if (respuesta.statusCode == 200) {
        _mostrarMensajeExito('Deber Actualizado');
        Navigator.pop(context, true); // Regresar con éxito
      }
    } catch (e) {
      _mostrarMensajeError('Error al guardar');
      print('Error al actualizar el Deber: $e');
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
    cargarDetalleDeber();
  }

  // Vista principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modo == 0 ? "Crear Deber" : "Editar Deber"),
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
                      labelText: 'Detalle del Deber',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 7,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_detalleController.text.isNotEmpty) {
                        if (widget.modo == 0) {
                          guardarDeber();
                        } else {
                          actualizarDeber();
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
