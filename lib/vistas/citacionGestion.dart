import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/globales.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorDeber.dart';

class ClaseCitacionGestion extends StatefulWidget {
  final String idUsuarioConsulta;
  final String idEstudiante;
  final String tipoUsuarioSesion;

  const ClaseCitacionGestion(
      this.idUsuarioConsulta, this.idEstudiante, this.tipoUsuarioSesion,
      {super.key});

  @override
  _CitacionGestionState createState() => _CitacionGestionState();
}

class _CitacionGestionState extends State<ClaseCitacionGestion> {
  //variables
  List<ConversorDeber> listaDeberes = [];
  String? _deberSeleccionado;
  final TextEditingController _detalleController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _esCitaDisciplinaria = false;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _detalleDisciplinarioController =
      TextEditingController();

  Future<void> _seleccionarHora(BuildContext context,
      DateTime? fechaSeleccionada, Function(DateTime) onTimeSelected) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    if (pickedTime != null && fechaSeleccionada != null) {
      final fechaConHora = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      onTimeSelected(
          fechaConHora); // Actualiza la fecha con la hora seleccionada
    }
  }

  Future<void> _seleccionarFechaHoraInicio(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'), // Muestra meses en español
    );

    if (picked != null) {
      _seleccionarHora(context, picked, (fechaConHora) {
        setState(() {
          _fechaInicio = fechaConHora;
        });
      });
    }
  }

  Future<void> _seleccionarFechaHoraFin(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      _seleccionarHora(context, picked, (fechaConHora) {
        setState(() {
          _fechaFin = fechaConHora;
        });
      });
    }
  }

  String _formatearFechaHora(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.year}/${fecha.month.toString().padLeft(2, '0')}/${fecha.day.toString().padLeft(2, '0')} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  //metodo por defecto de inicio
  @override
  void initState() {
    super.initState();
    traerdeberes();
  }

  //este procedimiento es para realizar el cargue de los deberes
  Future<void> traerdeberes() async {
    try {
      final respuesta = await Dio()
          .get('${GlobalesClass.direccionApi}/deber/lista/DeberEstudiantes');

      if (respuesta.statusCode == 200) {
        List<dynamic> data = respuesta.data;
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          listaDeberes = dataList
              .map((elemento) => ConversorDeber.fromJson(elemento))
              .toList();
          if (listaDeberes.isNotEmpty) {
            _deberSeleccionado = listaDeberes.first.detalle;
          }
        });
      }
    } catch (e) {
      print('Error al cargar derechos: $e');
    }
  }

  //funcion para guardar una citacion
  Future<bool> guardarCitacion() async {
    try {
      final respuesta = await Dio()
          .post('${GlobalesClass.direccionApi}/citacion/CrearCitacion', data: {
        "DETALLE": _detalleController.text,
        "FECHAINICIO": _formatearFechaHora(_fechaInicio),
        "FECHAFIN": _formatearFechaHora(_fechaFin),
        "USUARIOCITACION": widget.idUsuarioConsulta
      });
      // Verificamos si la respuesta fue exitosa (código 200)
      if (respuesta.statusCode == 200) {
        print('Citacion Creado exitosamente: ${respuesta.data.toString()}');
        return true;
      } else {
        print('Error al Crear Citacion: ${respuesta.data.toString()}');
        return false;
      }
    } catch (error) {
      print('Error al Crear Citacion: ${error.toString()}');
      return false;
    }
  }

  //funcion para guardar un registro de observador
  Future<bool> guardarObservador() async {
    try {
      final respuesta = await Dio().post(
          '${GlobalesClass.direccionApi}/observador/CrearObservador',
          data: {
            "TITULO": _tituloController.text,
            "DETALLE": _detalleDisciplinarioController.text,
            "USUARIOOBSERVACION": widget.idEstudiante
          });
      // Verificamos si la respuesta fue exitosa (código 200)
      if (respuesta.statusCode == 200) {
        print('Exito al guardar observador: ${respuesta.data.toString()}');
        return true;
      } else {
        print('Error al guardar observador: ${respuesta.data.toString()}');
        return false;
      }
    } catch (error) {
      print('Error al guardar observador: ${error.toString()}');
      return false;
    }
  }

  //funcion para guardar informacion en la tabla intermedia
  Future<bool> guardarCitacionObservador() async {
    try {
      final respuesta =
          await Dio().post('${GlobalesClass.direccionApi}/citacion/Intermedia');
      // Verificamos si la respuesta fue exitosa (código 200)
      if (respuesta.statusCode == 200) {
        print('Crear CIT-OBS exitoso : ${respuesta.data.toString()}');
        return true;
      } else {
        print(
            'Error al Crear Vinculacion CIT-OBS : ${respuesta.data.toString()}');
        return false;
      }
    } catch (error) {
      print('Error al Crear Vinculacion CIT-OBS : ${error.toString()}');
      return false;
    }
  }

// Método para gestionar notificaciones
  Future<bool> notificarUsuarios() async {
    List<String> listaTokens = [];
    // Realizar la petición al API
    final respuesta = await Dio().get(
        '${GlobalesClass.direccionApi}/usuario/ConsultaToken/Usuario/${widget.idUsuarioConsulta}');

    // Verificar si la respuesta fue exitosa
    if (respuesta.statusCode == 200) {
      // Recorrer la respuesta (lista de tokens)
      for (var usuario in respuesta.data) {
        // Almacenar cada TOKEN en el array de tokens
        if (usuario['TOKEN'] != null) {
          listaTokens.add(usuario['TOKEN']);
        }
      }
      // Llamar a la función auxiliarNotificacion pasándole la lista de tokens
      if (listaTokens.isNotEmpty) {
        if (await auxiliarNotificacion(listaTokens)) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  // Función auxiliar para enviar la lista de tokens
  Future<bool> auxiliarNotificacion(List<String> tokens) async {
    // Realizar la petición al API
    final respuesta =
        await Dio().post('${GlobalesClass.direccionApi}/notification', data: {
      "title": "Citación pendiente",
      "body": "Ha sido citado para el día: " +
          _formatearFechaHora(_fechaInicio) +
          ".\nRevisar citaciones para más detalles.",
      "deviceId": tokens
    });
    // Verificar si la respuesta fue exitosa
    if (respuesta.statusCode == 201) {
      print('Notificaciones correctas');
      return true;
    } else {
      print('Error al notificar: ${respuesta.data.toString()}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Citación"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _detalleController,
                maxLines: 3,
                maxLength: 250,
                cursorColor: Colors.blue,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Detalle*',
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
              _buildDateButton(() => _seleccionarFechaHoraInicio(context),
                  "Seleccionar Fecha de Inicio*"),
              const SizedBox(height: 16),
              _buildDateField("Fecha de Fin", _formatearFechaHora(_fechaFin)),
              _buildDateButton(() => _seleccionarFechaHoraFin(context),
                  "Seleccionar Fecha de Fin*"),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Citación disciplinaria'),
                value: _esCitaDisciplinaria,
                onChanged: (value) {
                  setState(() {
                    _esCitaDisciplinaria = value;
                  });
                },
              ),
              if (_esCitaDisciplinaria) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Deber Incumplido*',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Colors.blue, // Borde en azul cuando está habilitado
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Colors.blue, // Borde en azul cuando está enfocado
                      ),
                    ),
                  ),
                  value: _deberSeleccionado,
                  items: listaDeberes.asMap().entries.map((entry) {
                    int index = entry.key;
                    ConversorDeber deber = entry.value;
                    // Alterna colores de fondo basado en el índice
                    Color backgroundColor =
                        index.isEven ? Colors.grey[100]! : Colors.grey[300]!;

                    return DropdownMenuItem<String>(
                      value: deber
                          .detalle, // Cambié a 'deber.detalle' en lugar de 'deber.codigo.toString()'
                      child: Container(
                        color:
                            backgroundColor, // Alterna entre gris claro y oscuro
                        padding: const EdgeInsets.symmetric(
                            vertical: 5), // Espaciado interno
                        child: Row(
                          children: [
                            const Icon(Icons.chevron_right, color: Colors.blue),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                deber.detalle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 15,
                                style: const TextStyle(
                                    color: Colors.black), // Texto en negro
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _deberSeleccionado =
                          newValue; // 'newValue' ahora será igual a 'deber.detalle'
                      _detalleDisciplinarioController.text = newValue ?? '';
                      _tituloController.text = 'Observación Disciplinaria';
                      print(_deberSeleccionado);
                    });
                  },
                  style: const TextStyle(color: Colors.blue), // Texto en azul
                  dropdownColor:
                      Colors.white, // Color del fondo del desplegable
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tituloController,
                  maxLength: 100,
                  cursorColor: Colors.blue,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Título*',
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
                  maxLines: 4,
                  maxLength: 500,
                  cursorColor: Colors.blue,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Detalle*',
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
              ElevatedButton(
                  onPressed: () async {
                    //verificar si debemos crear, citacion y observacion, o solo citacion
                    //citacion y observacion
                    //Validamos campos
                    if (_esCitaDisciplinaria) {
                      if (_detalleController.text != '' &&
                          _fechaInicio != null &&
                          _fechaFin != null &&
                          _tituloController.text != '' &&
                          _detalleDisciplinarioController.text != '') {
                        if (await guardarObservador()) {
                          //Si el proceso de registrar el observador con exito, seguimos con la citacion
                          if (await guardarCitacion()) {
                            //si se guarda correctamente la citacion, guardamos la tabla intermedia
                            if (await guardarCitacionObservador()) {
                              notificarUsuarios();
                              final snackBar = SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Información',
                                  message: 'Se ha creado la citación',
                                  contentType: ContentType.success,
                                ),
                              );

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(snackBar);
                              Navigator.pop(context);
                            } else {
                              final snackBar = SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Información',
                                  message:
                                      'Ocurrió un problema al vincular la citación con la observación',
                                  contentType: ContentType.failure,
                                ),
                              );

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(snackBar);
                              Navigator.pop(context);
                            }
                          } else {
                            final snackBar = SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Información',
                                message:
                                    'Ocurrió un problema al crear la citación',
                                contentType: ContentType.failure,
                              ),
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
                            Navigator.pop(context);
                          }
                        } else {
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Información',
                              message:
                                  'Ocurrió un problema al crear la observación',
                              contentType: ContentType.failure,
                            ),
                          );

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                          Navigator.pop(context);
                        }
                      }
                    }
                    //solo citacion
                    else {
                      //validacion de campos requeridos
                      if (_detalleController.text != '' &&
                          _fechaInicio != null &&
                          _fechaFin != null) {
                        if (await guardarCitacion()) {
                          notificarUsuarios();
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Información',
                              message: 'Se ha creado la citación',
                              contentType: ContentType.success,
                            ),
                          );

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                          Navigator.pop(context);
                        } else {
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Información',
                              message:
                                  'Ocurrió un problema al crear la citación',
                              contentType: ContentType.failure,
                            ),
                          );

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                          Navigator.pop(context);
                        }
                      } else {
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Información',
                            message:
                                'Completar los datos necesarios (*) para crear la citación',
                            contentType: ContentType.warning,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[200],
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.black),
                  )),
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

  // Widget para botón de selección de fecha
  Widget _buildDateButton(VoidCallback onPressed, String label) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_today, color: Colors.blue),
      label: Text(label, style: const TextStyle(color: Colors.blue)),
    );
  }
}
