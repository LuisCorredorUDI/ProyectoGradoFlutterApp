import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_grado_app/globales.dart';
import 'package:proyecto_grado_app/services/bloc/notificaciones_bloc.dart';
import 'package:proyecto_grado_app/vistas/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClaseLogin extends StatefulWidget {
  const ClaseLogin({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<ClaseLogin>
//Login state inicio
{
  @override
  void initState() {
    super.initState();
    context.read<NotificacionesBloc>().pedirPermisosUsuario();
    _CargarPreferencias();
  }

  _CargarPreferencias() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? idUsuarioGuardado = prefs.getString('ID');
    final String? nombreUsuarioGuardado = prefs.getString('NOMBRES');
    final String? tipoUsuarioGuardado = prefs.getString('CODIGOTIPOUSUARIO');

    if (idUsuarioGuardado != null &&
        nombreUsuarioGuardado != null &&
        tipoUsuarioGuardado != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(idUsuarioGuardado,
                  nombreUsuarioGuardado, tipoUsuarioGuardado)));
    }
  }

  //Controladores
  TextEditingController controladorDocumento = TextEditingController();
  TextEditingController controladorClave = TextEditingController();
  dynamic datosUsuario;

//consultamos el usuario que quiere iniciar sesion
  Future<bool> consultaUsuario(
      BuildContext context, String documento, String clave) async {
    try {
      final dio = Dio();

      // Configurar el tiempo límite (timeout) para la solicitud
      dio.options.connectTimeout =
          const Duration(seconds: 5); // 10 segundos de tiempo límite
      dio.options.receiveTimeout =
          const Duration(seconds: 5); // 10 segundos para recibir respuesta

      // Realizar la solicitud HTTP
      final respuesta = await dio
          .get('${GlobalesClass.direccionApi}/usuario/$documento/$clave');

      if (respuesta.data != '') {
        // Procesar los datos recibidos
        datosUsuario = respuesta.data;
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      // Manejar el error si es un timeout o problemas de conexión
      if (e.type == DioErrorType.connectionTimeout ||
          e.type == DioErrorType.receiveTimeout) {
        _mostrarMensajeError(context,
            'Tiempo de espera agotado. Revisa tu conexión a internet e intenta más tarde.');
      } else if (e.type == DioErrorType.connectionError) {
        _mostrarMensajeError(context,
            'No se ha podido obtener una respuesta válida del servidor. Revisa tu conexión a internet e intenta más tarde.');
      } else {
        _mostrarMensajeError(context, 'Ha ocurrido un error inesperado.');
      }
      return false;
    }
  }

// Función para mostrar un mensaje de error en pantalla
  void _mostrarMensajeError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/recursos/loginback.jpg"),
              fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 200,
              left: 50,
              right: 50,
              child: _FormularioLogin(),
            ),
            Positioned(
              top: 250,
              left: 50,
              right: 50,
              child: _InputFieldsConstructor(controladorDocumento, "Documento"),
            ),
            Positioned(
              top: 300,
              left: 50,
              right: 50,
              child: _InputFieldsConstructor(controladorClave, "Clave",
                  esClave: true),
            ),
            Positioned(
              top: 350,
              left: 50,
              right: 50,
              child: _BotonConstructor(),
            ),
          ],
        ),
      ),
    );
  }

// Formulario
// ignore: non_constant_identifier_names
  Widget _FormularioLogin() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bienvenido",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

// Cajas
// ignore: non_constant_identifier_names
  Widget _InputFieldsConstructor(
      TextEditingController controlador, String hintText,
      {bool esClave = false}) {
    return TextField(
      controller: controlador,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        suffixIcon: esClave
            ? const Icon(
                Icons.remove_red_eye,
                color: Colors.white,
              )
            : const Icon(Icons.done, color: Colors.white),
        hintText: hintText, // Texto de sugerencia
        hintStyle: const TextStyle(color: Colors.white70),
        focusedBorder: const UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // Borde cuando está enfocado
        ),
      ),
      obscureText: esClave,
    );
  }

// Botón
// ignore: non_constant_identifier_names
  Widget _BotonConstructor() {
    return Container(
      margin: const EdgeInsets.all(5), // Margen de 5 píxeles
      child: ElevatedButton(
        onPressed: () async {
          //Tomamos variables
          String documentoLogin = controladorDocumento.text;
          String claveLogin = controladorClave.text;

          debugPrint('doc: $documentoLogin');
          debugPrint('clave: $claveLogin');
          //Validar cajas de texto
          if (documentoLogin != '' && claveLogin != '') {
            //verificamos si encontro el usuario
            // ignore: unrelated_type_equality_checks
            if (!(await consultaUsuario(
                context, controladorDocumento.text, controladorClave.text))) {
              //Aviso al usuario
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message: 'Credenciales erróneas o usuario inactivo',
                  contentType: ContentType.failure,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            } else {
              var idUsuarioEnvia = datosUsuario["ID"].toString();
              String nombreUsuarioEnvia = datosUsuario["NOMBRES"];
              var tipoUsuarioEnvia =
                  datosUsuario["CODIGOTIPOUSUARIO"].toString();
              //Guardar preferencias de inicio de sesion
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setString('ID', idUsuarioEnvia);
              await prefs.setString('NOMBRES', nombreUsuarioEnvia);
              await prefs.setString('CODIGOTIPOUSUARIO', tipoUsuarioEnvia);
              //navigator
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(idUsuarioEnvia,
                          nombreUsuarioEnvia, tipoUsuarioEnvia)));
              //Aviso al usuario
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Información',
                  message: 'Inicio de sesión exitoso.',
                  contentType: ContentType.success,
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
                    'Información incompleta, es necesario diligenciar los campos de documento y contraseña',
                contentType: ContentType.failure,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 20,
          minimumSize: const Size.fromHeight(60),
          foregroundColor: Colors.blue[800], // Color del texto
        ),
        child: const Text("Ingresar"),
      ),
    );
  }

//Login state fin
}
