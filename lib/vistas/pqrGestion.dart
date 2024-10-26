import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorDerecho.dart';
import 'package:proyecto_grado_app/globales.dart';

class ClasePqrGestion extends StatefulWidget {
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;
  final String idUsuarioConsulta;

  const ClasePqrGestion(
    this.idUsuarioSesion,
    this.nombreUsuarioSesion,
    this.tipoUsuarioSesion,
    this.idUsuarioConsulta, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _PqrGestionState();
}

class _PqrGestionState extends State<ClasePqrGestion> {
  //Variables
  List<ConversorDerecho> listaDerechos = [];
  final TextEditingController _detallePqrController = TextEditingController();
  final List<String> _tiposPqr = [
    'Queja',
    'Reclamo',
    'Sugerencia',
    'Felicitación'
  ];
  String? _tipoPqrSeleccionado;
  String? _derechoSeleccionado;

  @override
  void initState() {
    super.initState();
    traerderechos();
  }

  Future<void> traerderechos() async {
    try {
      final respuesta = await Dio().get(
          '${GlobalesClass.direccionApi}/derecho/' + widget.tipoUsuarioSesion);

      if (respuesta.statusCode == 200) {
        List<dynamic> data = respuesta.data;
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          listaDerechos = dataList
              .map((elemento) => ConversorDerecho.fromJson(elemento))
              .toList();
          if (listaDerechos.isNotEmpty) {
            _derechoSeleccionado = listaDerechos.first.codigo.toString();
          }
        });
      }
    } catch (e) {
      print('Error al cargar derechos: $e');
    }
  }

  // ignore: non_constant_identifier_names
  Future<bool> GuardarPqrAPI() async {
    //Variables
    int tipoPqr = 0;

    if (_tipoPqrSeleccionado == 'Queja') {
      tipoPqr = 1;
    } else if (_tipoPqrSeleccionado == 'Reclamo') {
      tipoPqr = 2;
    } else if (_tipoPqrSeleccionado == 'Sugerencia') {
      tipoPqr = 3;
    } else if (_tipoPqrSeleccionado == 'Felicitación') {
      tipoPqr = 4;
    }
    //Si esta nulo, mandamos el texto directo
    _derechoSeleccionado ??= 'NULL';

    final respuesta = await Dio().post(
      '${GlobalesClass.direccionApi}/pqr/CrearPqr',
      data: {
        "DETALLE": _detallePqrController.text,
        "TIPOPQR": tipoPqr,
        "USUARIOGENERA": widget.idUsuarioSesion,
        "CODIGODERECHO": _derechoSeleccionado,
      },
    );
    // Verificamos si la respuesta fue exitosa (código 200)
    if (respuesta.statusCode == 200) {
      print('Usuario creado exitosamente: ${respuesta.data.toString()}');
      return true;
    } else {
      print('Error al crear usuario: ${respuesta.data.toString()}');
      return false;
    }
  }

  //Vista principal inicio
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear PQR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _detallePqrController,
                maxLength: 500,
                maxLines: 5,
                cursorColor: Colors.blue, // Color del cursor
                decoration: const InputDecoration(
                  labelText: 'Detalle de la PQR*',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // Borde en azul
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .blue), // Borde en azul cuando está habilitado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Colors.blue), // Borde en azul cuando está enfocado
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de PQR*',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .blue), // Borde en azul cuando está habilitado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Colors.blue), // Borde en azul cuando está enfocado
                  ),
                ),
                value: _tipoPqrSeleccionado,
                items: _tiposPqr.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoPqrSeleccionado = newValue;
                  });
                },
                dropdownColor: Colors.white, // Color del fondo del desplegable
                isExpanded: true,
              ),
              const SizedBox(height: 20),
              // Mostrar "Derecho Vulnerado" solo si el tipo de PQR es "Queja" o "Reclamo"
              if (_tipoPqrSeleccionado == 'Queja' ||
                  _tipoPqrSeleccionado == 'Reclamo')
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Derecho Vulnerado*',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .blue), // Borde en azul cuando está habilitado
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .blue), // Borde en azul cuando está enfocado
                    ),
                  ),
                  value: _derechoSeleccionado,
                  items: listaDerechos.asMap().entries.map((entry) {
                    int index = entry.key;
                    ConversorDerecho derecho = entry.value;
                    // Alterna colores de fondo basado en el índice
                    Color backgroundColor =
                        index.isEven ? Colors.grey[100]! : Colors.grey[300]!;

                    return DropdownMenuItem<String>(
                      value: derecho.codigo.toString(),
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
                                derecho.detalle,
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
                      _derechoSeleccionado = newValue;
                      print(_derechoSeleccionado);
                    });
                  },
                  style: const TextStyle(color: Colors.blue), // Texto en azul
                  dropdownColor:
                      Colors.white, // Color del fondo del desplegable
                  isExpanded: true,
                ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_detallePqrController.text != '' &&
                        _tipoPqrSeleccionado != null) {
                      if (await GuardarPqrAPI()) {
                        //Aviso al usuario
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Información',
                            message: 'Se ha guardado la PQR de forma correcta.',
                            contentType: ContentType.success,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                        Navigator.pop(context);
                      } else {
                        //Aviso al usuario
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Información',
                            message: 'Error al guardar la PQR.',
                            contentType: ContentType.warning,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      }
                    } else {
                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Información',
                          message:
                              'Los campos identificados con * son obligatorios.',
                          contentType: ContentType.help,
                        ),
                      );

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    }
                  },
                  child: const Text('Guardar PQR'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  //Vista principal fin
}
