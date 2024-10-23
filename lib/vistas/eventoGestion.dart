import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // Para la conversión de imagen a base64

class ClaseEventoGestion extends StatefulWidget {
  final String idUsuarioSesion;

  const ClaseEventoGestion(this.idUsuarioSesion, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClaseEventoGestionState createState() => _ClaseEventoGestionState();
}

class _ClaseEventoGestionState extends State<ClaseEventoGestion> {
  // Variables para controlar los inputs
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  File? _imagen;

  // Método para validar campos
  bool _validarCampos() {
    if (_nombreController.text.isEmpty ||
        _detalleController.text.isEmpty ||
        _fechaInicio == null ||
        _fechaFin == null) {
      return false;
    }
    return true;
  }

  // Método para guardar la información
  Future<bool> GuardarEventoAPI() async {
    String? imagenBase64;
    if (_imagen != null) {
      // Convertimos la imagen en base64
      List<int> imagenBytes = await _imagen!.readAsBytes();
      imagenBase64 = base64Encode(imagenBytes);
    } else {
      imagenBase64 = ""; // Si no hay imagen, enviamos un valor vacío
    }

    // Realizar la petición al API
    final respuesta = await Dio().post(
      'http://10.0.2.2:3000/evento/CrearEvento',
      data: {
        "NOMBRE": _nombreController.text,
        "DETALLE": _detalleController.text,
        "FECHAINICIO": _formatearFechaHora(_fechaInicio),
        "FECHAFIN": _formatearFechaHora(_fechaFin),
        "IMAGEN": imagenBase64, // Enviar imagen como base64 o vacío
        "IDUSUARIOCREACION": widget.idUsuarioSesion,
      },
    );
    // Verificamos si la respuesta fue exitosa (código 200)
    if (respuesta.statusCode == 200) {
      if (await notificarUsuarios()) {
        print('Evento creado exitosamente, Notificado correcto');
      } else {
        print('Evento creado exitosamente, Problemas en la notificacion');
      }
      return true;
    } else {
      print('Error al crear evento: ${respuesta.data.toString()}');
      return false;
    }
  }

// Método para gestionar notificaciones
  Future<bool> notificarUsuarios() async {
    List<String> listaTokens = [];
    // Realizar la petición al API
    final respuesta =
        await Dio().get('http://10.0.2.2:3000/usuario/ConsultaToken');

    // Verificar si la respuesta fue exitosa
    if (respuesta.statusCode == 200) {
      // Recorrer la respuesta (lista de tokens)
      for (var usuario in respuesta.data) {
        // Almacenar cada TOKEN en el array de tokens
        listaTokens.add(usuario['TOKEN']);
      }
      // Llamar a la función auxiliarNotificacion pasándole la lista de tokens
      if (await auxiliarNotificacion(listaTokens)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  // Función auxiliar para enviar la lista de tokens
  Future<bool> auxiliarNotificacion(List<String> tokens) async {
    // Realizar la petición al API
    final respuesta =
        await Dio().post('http://10.0.2.2:3000/notification', data: {
      "title": "Nuevo evento publicado",
      "body": _nombreController.text,
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

  // Método para seleccionar imagen
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagen = File(pickedFile.path);
      });
    }
  }

  // Método para seleccionar hora
  Future<void> _seleccionarHora(BuildContext context,
      DateTime? fechaSeleccionada, Function(DateTime) onTimeSelected) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    if (pickedTime != null) {
      final fechaConHora = DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      onTimeSelected(
          fechaConHora); // Actualiza la fecha con la hora seleccionada
    }
  }

  // Método para seleccionar fecha y hora para fecha de inicio
  Future<void> _seleccionarFechaHoraInicio(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      _seleccionarHora(context, picked, (fechaConHora) {
        setState(() {
          _fechaInicio = fechaConHora;
        });
      });
    }
  }

  // Método para seleccionar fecha y hora para fecha de fin
  Future<void> _seleccionarFechaHoraFin(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      _seleccionarHora(context, picked, (fechaConHora) {
        setState(() {
          _fechaFin = fechaConHora;
        });
      });
    }
  }

  // Método actualizado para formatear la fecha y hora
  String _formatearFechaHora(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.year}/${fecha.month}/${fecha.day} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Evento"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              _buildTextField("Nombre del Evento", _nombreController),
              const SizedBox(height: 16),
              _buildTextField("Detalle del Evento", _detalleController,
                  maxLength: 250),
              const SizedBox(height: 16),
              _buildDateField(
                  "Fecha de Inicio", _formatearFechaHora(_fechaInicio)),
              _buildDateButton(() => _seleccionarFechaHoraInicio(context),
                  "Seleccionar Fecha de Inicio"),
              const SizedBox(height: 16),
              _buildDateField("Fecha de Fin", _formatearFechaHora(_fechaFin)),
              _buildDateButton(() => _seleccionarFechaHoraFin(context),
                  "Seleccionar Fecha de Fin"),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Validar campos antes de enviar
                  if (_validarCampos()) {
                    if (await GuardarEventoAPI()) {
                      // Aviso al usuario
                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Información',
                          message: 'Evento guardado exitosamente.',
                          contentType: ContentType.success,
                        ),
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                      Navigator.pop(context);
                    } else {
                      // Aviso de error
                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Error',
                          message: 'Ocurrió un error al guardar el evento.',
                          contentType: ContentType.failure,
                        ),
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    }
                  } else {
                    // Aviso de campos faltantes
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Advertencia',
                        message:
                            'Por favor, complete todos los campos obligatorios.',
                        contentType: ContentType.warning,
                      ),
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text("Crear Evento"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para campos de texto
  Widget _buildTextField(String label, TextEditingController controller,
      {int? maxLength}) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      cursorColor: Colors.blue,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

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

  // Widget para selección de imagen
  Widget _buildImagePicker() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _seleccionarImagen,
          icon: const Icon(Icons.image),
          label: const Text('Seleccionar Imagen'),
        ),
        if (_imagen != null)
          Column(
            children: [
              const SizedBox(height: 16),
              Image.file(_imagen!, height: 100, width: 100),
            ],
          ),
      ],
    );
  }
}
