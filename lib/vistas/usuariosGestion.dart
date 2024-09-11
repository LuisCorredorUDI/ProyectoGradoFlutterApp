import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClaseUsuarioGestion extends StatefulWidget {
  //Variables globales
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;
  final String idUsuarioConsulta;
  //Modo 0 = creacion, modo 1 = edicion
  final int modo;

  const ClaseUsuarioGestion(this.idUsuarioSesion, this.nombreUsuarioSesion,
      this.tipoUsuarioSesion, this.idUsuarioConsulta, this.modo,
      {super.key});

  @override
  State<StatefulWidget> createState() => _UsuarioGestionState();
}

//INICIO STATE
class _UsuarioGestionState extends State<ClaseUsuarioGestion> {
  //VARIABLES GLOBALES
  // Controladores de texto para cada campo
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController documentoController = TextEditingController();
  final TextEditingController claveIngresoController = TextEditingController();
  final TextEditingController fechaNacimientoController =
      TextEditingController();
  final TextEditingController numeroTelefonoController =
      TextEditingController();
  final TextEditingController numeroMovilController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  // Variables para las listas desplegables
  String? estadoSeleccionado;
  String? tipoUsuarioSeleccionado;

  // Lista de opciones para Estado
  final List<String> estados = ['Activo', 'Inactivo'];

  // Lista de opciones para Tipo de Usuario
  final List<String> tiposUsuario = ['Coordinador', 'Acudiente', 'Estudiante'];

  //funcion de inicio
  @override
  void initState() {
    super.initState();
    //aqui validamos si es, una creacion, edicion o consulta.
    if (widget.idUsuarioConsulta != '0') {
      CargarDatosIniciales(widget.idUsuarioConsulta);
    }
  }

  //FUNCION DE CARGUE DE DATOS, EN CASO DE CONSULTA O EDICION.
  Future<void> CargarDatosIniciales(String idUsuarioConsulta) async {
    final respuesta = await Dio().get(
        'http://10.0.2.2:3000/usuario/DetalleUsuario/' + idUsuarioConsulta);
    //Variables para fechas
    DateTime parsedDate;
    String formattedDate;
    if (respuesta.statusCode == 200) {
      setState(() {
        // Asegurarse de que el cambio se refleje en la UI
        nombresController.text = respuesta.data['NOMBRES'].toString();
        apellidosController.text = respuesta.data['APELLIDOS'].toString();
        documentoController.text = respuesta.data['DOCUMENTO'].toString();
        claveIngresoController.text = respuesta.data['CLAVEINGRESO'].toString();
        parsedDate =
            DateTime.parse(respuesta.data['FECHANACIMIENTO'].toString());
        formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        fechaNacimientoController.text = formattedDate;

        if (respuesta.data['NUMEROTELEFONO'] != null) {
          numeroTelefonoController.text =
              respuesta.data['NUMEROTELEFONO'].toString();
        }
        numeroMovilController.text = respuesta.data['NUMEROMOVIL'].toString();

        if (respuesta.data['CORREO'] != null) {
          correoController.text = respuesta.data['CORREO'].toString();
        }
        if (respuesta.data['DIRECCION'] != null) {
          direccionController.text = respuesta.data['DIRECCION'].toString();
        }

        //combo estado
        if (respuesta.data['ESTADO'] == 1) {
          estadoSeleccionado = 'Activo';
        } else if (respuesta.data['ESTADO'] == 0) {
          estadoSeleccionado = 'Inactivo';
        }

        //combo tipo
        if (respuesta.data['CODIGOTIPOUSUARIO'] == 1) {
          tipoUsuarioSeleccionado = 'Coordinador';
        } else if (respuesta.data['CODIGOTIPOUSUARIO'] == 2) {
          tipoUsuarioSeleccionado = 'Acudiente';
        } else if (respuesta.data['CODIGOTIPOUSUARIO'] == 3) {
          tipoUsuarioSeleccionado = 'Estudiante';
        }
      });
    }
  }

  //Funcion para el guardado de usuarios
  // ignore: non_constant_identifier_names
  Future<bool> GuardarUsuarioAPI() async {
    try {
      int codigoTipoUsuario;
      int codigoEstadoUsuario;
      //tipo usuario
      if (tipoUsuarioSeleccionado == 'Coordinador') {
        codigoTipoUsuario = 1;
      } else if (tipoUsuarioSeleccionado == 'Acudiente') {
        codigoTipoUsuario = 2;
      } else if (tipoUsuarioSeleccionado == 'Estudiante') {
        codigoTipoUsuario = 3;
      } else {
        // Si por alguna razón no hay selección válida, podemos lanzar un error o manejarlo de otra forma
        throw Exception('Tipo de usuario no válido');
      }
      //estado
      if (estadoSeleccionado == 'Activo') {
        codigoEstadoUsuario = 1;
      } else if (estadoSeleccionado == 'Inactivo') {
        codigoEstadoUsuario = 0;
      } else {
        // Si por alguna razón no hay selección válida, podemos lanzar un error o manejarlo de otra forma
        throw Exception('Estado no válido');
      }

      //Variable para realizar la peticion al API
      final respuesta;
      if (widget.modo == 0) {
        respuesta = await Dio().post(
          'http://10.0.2.2:3000/usuario/CrearUsuario',
          data: {
            "NOMBRES": nombresController.text,
            "APELLIDOS": apellidosController.text,
            "DOCUMENTO": documentoController.text,
            "CLAVEINGRESO": claveIngresoController.text,
            "FECHANACIMIENTO": fechaNacimientoController.text,
            "NUMEROTELEFONO": numeroTelefonoController.text,
            "NUMEROMOVIL": numeroMovilController.text,
            "CORREO": correoController.text,
            "DIRECCION": direccionController.text,
            "ESTADO": codigoEstadoUsuario,
            "CODIGOTIPOUSUARIO": codigoTipoUsuario,
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
      } else if (widget.modo == 1) {
        respuesta = await Dio().patch(
          'http://10.0.2.2:3000/usuario/ActualizarUsuario/${widget.idUsuarioConsulta}',
          data: {
            "NOMBRES": nombresController.text,
            "APELLIDOS": apellidosController.text,
            "DOCUMENTO": documentoController.text,
            "CLAVEINGRESO": claveIngresoController.text,
            "FECHANACIMIENTO": fechaNacimientoController.text,
            "NUMEROTELEFONO": numeroTelefonoController.text,
            "NUMEROMOVIL": numeroMovilController.text,
            "CORREO": correoController.text,
            "DIRECCION": direccionController.text,
            "ESTADO": codigoEstadoUsuario,
            "CODIGOTIPOUSUARIO": codigoTipoUsuario,
          },
        );
        // Verificamos si la respuesta fue exitosa (código 200)
        if (respuesta.statusCode == 200) {
          print('Usuario Editado exitosamente: ${respuesta.data.toString()}');
          return true;
        } else {
          print('Error al Editar usuario: ${respuesta.data.toString()}');
          return false;
        }
      } else {
        return false;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Error en respuesta del servidor: ${e.response?.data}');
      } else {
        print('Error de conexión o de solicitud: ${e.message}');
      }
      return false;
    } catch (e) {
      print('Error inesperado: $e');
      return false;
    }
  }

  //funcion para eliminacion de usuarios
  Future<bool> EliminarUsuario() async {
    final respuesta = await Dio().delete(
        'http://10.0.2.2:3000/usuario/EliminarUsuario/' +
            widget.idUsuarioConsulta);
    // Verificamos si la respuesta fue exitosa (código 200)
    if (respuesta.statusCode == 200) {
      print('Usuario eliminado exitosamente: ${respuesta.data.toString()}');
      return true;
    } else {
      print('Error al eliminar usuario: ${respuesta.data.toString()}');
      return false;
    }
  }

  // Método para seleccionar fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fechaNacimientoController.text =
            "${picked.toLocal()}".split(' ')[0]; // Formato de fecha
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle Usuario"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(nombresController, 'NOMBRES*'),
              _buildTextField(apellidosController, 'APELLIDOS*'),
              _buildTextField(documentoController, 'DOCUMENTO*',
                  keyboardType: TextInputType.number),
              _buildTextField(claveIngresoController, 'CLAVE INGRESO*',
                  obscureText: true),
              _buildDateField(
                  context, fechaNacimientoController, 'FECHA NACIMIENTO*'),
              _buildTextField(numeroTelefonoController, 'NUMERO TELEFONO',
                  keyboardType: TextInputType.number),
              _buildTextField(numeroMovilController, 'NUMERO MOVIL*',
                  keyboardType: TextInputType.number),
              _buildTextField(correoController, 'CORREO',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(direccionController, 'DIRECCION'),
              _buildDropdownField('ESTADO*', estados, (String? newValue) {
                setState(() {
                  estadoSeleccionado = newValue;
                });
              }, estadoSeleccionado),
              _buildDropdownFieldTipoUsuario(
                'TIPO DE USUARIO*',
                tiposUsuario,
                (String? newValue) {
                  setState(() {
                    tipoUsuarioSeleccionado =
                        newValue; // Guardamos el nombre seleccionado
                  });
                },
                tipoUsuarioSeleccionado,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Acciones de guardado
                      if (nombresController.text != '' &&
                          apellidosController.text != '' &&
                          documentoController.text != '' &&
                          claveIngresoController.text != '' &&
                          fechaNacimientoController.text != '' &&
                          numeroMovilController.text != '' &&
                          estadoSeleccionado != '' &&
                          tipoUsuarioSeleccionado != null) {
                        // Verificar si es null
                        if (await GuardarUsuarioAPI()) {
                          //Aviso al usuario
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Información',
                              message:
                                  'Se ha guardado el usuario de forma correcta.',
                              contentType: ContentType.success,
                            ),
                          );

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                          Navigator.pop(context);
                          /*Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClaseUsuario(
                                  widget.idUsuarioSesion,
                                  widget.nombreUsuarioSesion,
                                  widget.tipoUsuarioSesion),
                            ),
                          );
                          */
                        } else {
                          //Aviso al usuario
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Información',
                              message:
                                  'Ocurrio un error al guardar el usuario.',
                              contentType: ContentType.failure,
                            ),
                          );

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                        }
                      } else {
                        //Aviso al usuario
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Información',
                            message:
                                'Los campos marcados con * son obligatorios.',
                            contentType: ContentType.warning,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.greenAccent[200], // Color primario
                    ),
                    child: const Text('Guardar Usuario'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Acciones de eliminación
                      if (await EliminarUsuario()) {
                        //Aviso al usuario
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Información',
                            message:
                                'Se ha eliminado el usuario de forma correcta.',
                            contentType: ContentType.warning,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                        //Cambio de vista
                        Navigator.pop(context);
                      } else {
                        //Aviso al usuario
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Información',
                            message:
                                'Se ha producido un error al eliminar el usuario.',
                            contentType: ContentType.failure,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                        //Cambio de vista
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[200], // Color primario
                    ),
                    child: const Text('Eliminar Usuario'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un campo de texto
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue), // Color del label
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.blue), // Color del borde cuando está enfocado
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.blue), // Color del borde cuando está habilitado
          ),
        ),
        cursorColor: Colors.blue, // Color del cursor
      ),
    );
  }

  // Método para construir un campo de fecha
  Widget _buildDateField(
      BuildContext context, TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.blue), // Color del label
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue), // Color del borde cuando está enfocado
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color:
                        Colors.blue), // Color del borde cuando está habilitado
              ),
            ),
            cursorColor: Colors.blue, // Color del cursor
          ),
        ),
      ),
    );
  }

  // Método para construir un campo desplegable
  Widget _buildDropdownField(String label, List<String> items,
      ValueChanged<String?> onChanged, String? selectedItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue), // Color del label
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.blue), // Color del borde cuando está enfocado
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.blue), // Color del borde cuando está habilitado
          ),
        ),
        value: selectedItem,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(color: Colors.black), // Color del texto
        dropdownColor: Colors.white, // Color del fondo del dropdown
      ),
    );
  }

  // Método para construir un campo desplegable de tipo de usuario
  Widget _buildDropdownFieldTipoUsuario(String label, List<String> items,
      ValueChanged<String?> onChanged, String? selectedItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue), // Color del label
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.blue), // Color del borde cuando está enfocado
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.blue), // Color del borde cuando está habilitado
          ),
        ),
        value: selectedItem,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(color: Colors.black), // Color del texto
        dropdownColor: Colors.white, // Color del fondo del dropdown
      ),
    );
  }

//FIN STATE
}
