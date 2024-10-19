import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorCitaciones.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_grado_app/vistas/citacionDetalle.dart'; // Paquete para formatear fechas

class ClaseCitacion extends StatefulWidget {
  //Variables
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  // 1 - coor, 2 - acu, 3 - est
  final String tipoUsuarioSesion;

  const ClaseCitacion(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _CitacionState();
}

class _CitacionState extends State<ClaseCitacion> {
  //Variables
  List<ConversorCitacion> citaciones = [];

  //funciones
  //Proceso de inicio por defecto
  @override
  void initState() {
    super.initState();
    if (widget.tipoUsuarioSesion == "1") {
      traerCitacionesFull();
    } else if (widget.tipoUsuarioSesion == "2") {
      traerCitacionesFill();
    }
  }

  //Para esperar el resultado de la vista de creacion
  Future<void> NavigateAndRefresh(
      BuildContext context, int codigoCitacion, int observaciones) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaseCitacionDetalle(
            codigoCitacion, observaciones, widget.tipoUsuarioSesion),
      ),
    );
    // Volver a cargar los eventos después de regresar
    if (widget.tipoUsuarioSesion == "1") {
      traerCitacionesFull();
    } else if (widget.tipoUsuarioSesion == "2") {
      traerCitacionesFill();
    }
  }

  // Función para la consulta de citaciones (todos los usuarios)
  Future<void> traerCitacionesFull() async {
    final respuesta =
        await Dio().get('http://10.0.2.2:3000/citacion/ListarCitaciones');
    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      setState(() {
        citaciones = data
            .map<ConversorCitacion>(
                (elemento) => ConversorCitacion.fromJson(elemento))
            .toList();
      });
    }
  }

  // Función para la consulta de citaciones (filtrado por usuario)
  Future<void> traerCitacionesFill() async {
    final respuesta = await Dio().get(
        'http://10.0.2.2:3000/citacion/ListarCitacionesFill/${widget.idUsuarioSesion}');
    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      setState(() {
        citaciones = data
            .map<ConversorCitacion>(
                (elemento) => ConversorCitacion.fromJson(elemento))
            .toList();
      });
    }
  }

  // Función para borrar una citacion con confirmación
  Future<bool> confirmarYBorrarCitacion(
      BuildContext context, int codigo) async {
    bool eliminado = false;

    // Mostrar el diálogo de confirmación
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text(
              "¿Está seguro de que desea eliminar esta citación? Esta acción es irreversible."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin eliminar
                eliminado = false; // No se realizó la eliminación
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                // Intentar eliminar el evento llamando a la API
                try {
                  final respuesta = await Dio().delete(
                      'http://10.0.2.2:3000/citacion/EliminarCitacion/$codigo');

                  // Si la respuesta es exitosa, retornamos true
                  if (respuesta.statusCode == 200) {
                    print('Citacion eliminado exitosamente: ${respuesta.data}');
                    eliminado = true;
                  } else {
                    print('Error al eliminar Citacion: ${respuesta.data}');
                    eliminado = false;
                  }
                } catch (e) {
                  // Manejo de excepciones y errores
                  print('Error durante la eliminación: $e');
                  eliminado = false;
                }
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child:
                  const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    return eliminado;
  }

  // Formatear la fecha en formato legible
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citaciones"),
      ),
      body: citaciones.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: citaciones.length,
              itemBuilder: (context, index) {
                final citacion = citaciones[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: InkWell(
                    // InkWell permite capturar el evento onTap
                    onTap: () {
                      NavigateAndRefresh(
                          context, citacion.codigo, citacion.citacionesnum);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            citacion.detalle ?? 'Sin Detalle',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha Inicio:',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatearFecha(citacion.fechainicio),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha Fin:',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatearFecha(citacion.fechafin),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Número de Observaciones:',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            citacion.citacionesnum?.toString() ?? 'N/A',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 4),
                          if (widget.tipoUsuarioSesion == '1') ...[
                            Text(
                              'Usuario Citado:',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              citacion.nombrecitado.toString(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                          const SizedBox(height: 4),
                          if (widget.tipoUsuarioSesion == '1')
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () async {
                                    bool respuesta =
                                        await confirmarYBorrarCitacion(
                                            context, citacion.codigo);
                                    if (respuesta) {
                                      // Aviso al usuario
                                      final snackBar = SnackBar(
                                        elevation: 0,
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        content: AwesomeSnackbarContent(
                                          title: 'Información',
                                          message:
                                              'Citación borrada exitosamente.',
                                          contentType: ContentType.success,
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(snackBar);
                                      // Después de intentar eliminar, actualizamos la lista
                                      traerCitacionesFull();
                                    } else {
                                      // Aviso al usuario
                                      final snackBar = SnackBar(
                                        elevation: 0,
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        content: AwesomeSnackbarContent(
                                          title: 'Información',
                                          message: 'No se elimino la Citación',
                                          contentType: ContentType.warning,
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(snackBar);
                                      // Después de intentar eliminar, actualizamos la lista
                                      traerCitacionesFull();
                                    }
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
//fin vista principal
}
