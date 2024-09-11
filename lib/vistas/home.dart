//Vista Home inicio
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/Observador.dart';
import 'package:proyecto_grado_app/vistas/citaciones.dart';
import 'package:proyecto_grado_app/vistas/login.dart';
import 'package:proyecto_grado_app/vistas/pqr.dart';
import 'package:proyecto_grado_app/vistas/usuarios.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Home page clase inicio
class HomePage extends StatefulWidget {
  //Variables globales
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;

  const HomePage(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

//Homestate estado inicio
class _HomeState extends State<HomePage> {
  //Variables
  String rutaFotoPerfil = '';
  String tipoPerfil = '';

  @override
  void initState() {
    super.initState();
    // Print para verificar los valores al iniciar el estado
    print('ID Usuario: ${widget.idUsuarioSesion}');
    print('Nombre Usuario: ${widget.nombreUsuarioSesion}');
    print('Tipo Usuario: ${widget.tipoUsuarioSesion}');

    if (widget.tipoUsuarioSesion == '1') {
      rutaFotoPerfil = 'lib/recursos/coor.png';
      tipoPerfil = 'Coordinador';
    } else if (widget.tipoUsuarioSesion == '2') {
      rutaFotoPerfil = 'lib/recursos/acu.png';
      tipoPerfil = 'Acudiente';
    } else if (widget.tipoUsuarioSesion == '3') {
      rutaFotoPerfil = 'lib/recursos/est.png';
      tipoPerfil = 'Estudiante';
    } else {
      rutaFotoPerfil = 'lib/recursos/acu.png';
      tipoPerfil = 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildMenu(context),
      appBar: AppBar(
        title: const Text("AGE App"),
      ),
      body: const Center(
        child: Text('Hello World!'),
      ),
    );
  }

  //Vista Menu Desplegable inicio
  Widget _buildMenu(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(top: 50),
              child: Image.asset(rutaFotoPerfil),
            ),
            Text(
              tipoPerfil,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            Text(
              widget.nombreUsuarioSesion,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(top: 10),
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseObservador(
                          widget.idUsuarioSesion,
                          widget.nombreUsuarioSesion,
                          widget.tipoUsuarioSesion),
                    ),
                  );
                },
                child: const Text('Observador'),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(top: 5),
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseCitaciones(
                          widget.idUsuarioSesion,
                          widget.nombreUsuarioSesion,
                          widget.tipoUsuarioSesion),
                    ),
                  );
                },
                child: const Text('Citaciones'),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(top: 5),
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClasePQR(widget.idUsuarioSesion,
                          widget.nombreUsuarioSesion, widget.tipoUsuarioSesion),
                    ),
                  );
                },
                child: const Text('PQR'),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(top: 5),
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseUsuario(widget.idUsuarioSesion,
                          widget.nombreUsuarioSesion, widget.tipoUsuarioSesion),
                    ),
                  );
                },
                child: const Text('Usuarios'),
              ),
            ),
            Expanded(child: Container()),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () async {
                  //Borramos preferencias
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('ID');
                  await prefs.remove('NOMBRES');
                  await prefs.remove('CODIGOTIPOUSUARIO');
                  //Navegamos al inicio de sesion
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseLogin(),
                    ),
                  );
                },
                child: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //Vista Menu Desplegable inicio

//Homestate estado FIN
}
