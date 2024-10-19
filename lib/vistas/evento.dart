import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/eventoGestion.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorEventoCoordinador.dart';

class ClaseEvento extends StatefulWidget {
  //Variables
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  // 1 - coor, 2 - acu, 3 - est
  final String tipoUsuarioSesion;

  const ClaseEvento(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _EventoState();
}

class _EventoState extends State<ClaseEvento> {
  // Lista de eventos
  List<ConversorEventoGestion> eventos = [];

  //Procedimientos
  //Proceso de inicio por defecto
  @override
  void initState() {
    super.initState();
    traerEventos(); // Cargar los eventos cuando se inicializa el widget
  }

  //Para esperar el resultado de la vista de creacion
  Future<void> NavigateAndRefresh(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaseEventoGestion(widget.idUsuarioSesion),
      ),
    );
    // Volver a cargar los eventos después de regresar
    traerEventos();
  }

  // Función para la consulta de eventos
  Future<void> traerEventos() async {
    final respuesta =
        await Dio().get('http://10.0.2.2:3000/evento/listaCoordinador');

    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      setState(() {
        eventos = data
            .map<ConversorEventoGestion>(
                (elemento) => ConversorEventoGestion.fromJson(elemento))
            .toList();
      });
    }
  }

  // Función para borrar un evento con confirmación
  Future<bool> confirmarYBorrarEvento(BuildContext context, int codigo) async {
    bool eliminado = false;

    // Mostrar el diálogo de confirmación
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text(
              "¿Está seguro de que desea eliminar este evento? Esta acción es irreversible."),
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
                      'http://10.0.2.2:3000/evento/EliminarEvento/$codigo');

                  // Si la respuesta es exitosa, retornamos true
                  if (respuesta.statusCode == 200) {
                    print('Evento eliminado exitosamente: ${respuesta.data}');
                    eliminado = true;
                  } else {
                    print('Error al eliminar evento: ${respuesta.data}');
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

  // Método actualizado para formatear la fecha y hora
  String _formatearFechaHora(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.year}/${fecha.month}/${fecha.day} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  //VISTA PRINCIPAL
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eventos"),
      ),
      body: Column(
        children: [
          // Botón para crear un evento
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
              onPressed: () {
                NavigateAndRefresh(context);
              },
              child: const Text(
                "Crear Evento",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          // Listado de eventos
          Expanded(
            child: ListView.builder(
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.blue), // Bordes azules
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Código del evento
                        Text(
                          "Código: ${evento.codigo}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Nombre del evento
                        Text(
                          "Nombre: ${evento.nombre}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        // Fecha del evento
                        Text(
                          "Fecha de Inicio: ${_formatearFechaHora(evento.fechainicio)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        // Botón para eliminar el evento
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool resultado = await confirmarYBorrarEvento(
                                  context, evento.codigo);
                              if (resultado) {
                                // Aviso al usuario
                                final snackBar = SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'Información',
                                    message: 'Evento borrado exitosamente.',
                                    contentType: ContentType.success,
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(snackBar);
                                // Después de intentar eliminar, actualizamos la lista
                                traerEventos();
                              } else {
                                // Aviso al usuario
                                final snackBar = SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'Información',
                                    message:
                                        'Eliminación cancelada. No se pudo realizar la eliminación del evento.',
                                    contentType: ContentType.failure,
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(snackBar);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
