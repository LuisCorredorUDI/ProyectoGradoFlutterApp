import 'dart:async';
import 'dart:convert'; // Para convertir Base64
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/acudiente.dart';
import 'package:proyecto_grado_app/vistas/evento.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorEventoHome.dart';
import 'package:proyecto_grado_app/vistas/citacion.dart';
import 'package:proyecto_grado_app/vistas/login.dart';
import 'package:proyecto_grado_app/vistas/pqr.dart';
import 'package:proyecto_grado_app/vistas/usuarios.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  // 1 - coor, 2 - acu, 3 - est
  final String tipoUsuarioSesion;

  const HomePage(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  String rutaFotoPerfil = '';
  String tipoPerfil = '';
  List<ConversorEventoHome> eventos = [];
  PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  bool cargando = true; // Agregar estado de carga

  @override
  void initState() {
    super.initState();
    //buscamos el listado de eventos
    traerEventos();
    // Determinamos el tipo de perfil
    if (widget.tipoUsuarioSesion == '1') {
      rutaFotoPerfil = 'lib/recursos/coor.png';
      tipoPerfil = 'Coordinador';
    } else if (widget.tipoUsuarioSesion == '2') {
      rutaFotoPerfil = 'lib/recursos/acu.png';
      tipoPerfil = 'Acudiente';
    } else {
      rutaFotoPerfil = 'lib/recursos/est.png';
      tipoPerfil = 'Estudiante';
    }
    // Iniciar temporizador para cambiar de página cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < eventos.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(_currentPage,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  Future<void> traerEventos() async {
    setState(() {
      cargando = true; // Inicia la carga
    });

    final respuesta = await Dio().get('http://10.0.2.2:3000/evento/listaHome');

    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      setState(() {
        eventos = data
            .map<ConversorEventoHome>(
                (elemento) => ConversorEventoHome.fromJson(elemento))
            .toList();
        cargando = false; // Finaliza la carga
      });
    } else {
      setState(() {
        cargando = false; // Finaliza la carga en caso de error
      });
      // Aquí podrías manejar el error si lo deseas
    }
  }

  // Método actualizado para formatear la fecha y hora
  String _formatearFechaHora(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.year}/${fecha.month}/${fecha.day} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  //evento cierre
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  //vista principal inicio
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildMenu(context),
      appBar: AppBar(title: const Text("ACE App")),
      body: cargando // Condición para mostrar el indicador de carga
          ? const Center(child: CircularProgressIndicator())
          : eventos.isEmpty
              ? const Center(child: Text("No hay eventos disponibles."))
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: eventos.length,
                        itemBuilder: (context, index) {
                          return _buildEventoBanner(eventos[index]);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            if (_currentPage > 0) {
                              _currentPage--;
                              _pageController.animateToPage(_currentPage,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            if (_currentPage < eventos.length - 1) {
                              _currentPage++;
                              _pageController.animateToPage(_currentPage,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
  //vista principal fin

  Widget _buildEventoBanner(ConversorEventoHome evento) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(evento.nombre,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildImagenEvento(evento.imagenarchivo),
          const SizedBox(height: 10),
          Text('Fecha Inicio: ${_formatearFechaHora(evento.fechainicio)}',
              style: const TextStyle(fontSize: 16)),
          Text('Fecha Fin: ${_formatearFechaHora(evento.fechafin)}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _mostrarDetalleEvento(context, evento.detalle),
            child: const Text("Ver más"),
          ),
        ],
      ),
    );
  }

  Widget _buildImagenEvento(String imagenBase64) {
    final bytes = base64Decode(imagenBase64);
    return Image.memory(bytes, width: 200, height: 150, fit: BoxFit.cover);
  }

  void _mostrarDetalleEvento(BuildContext context, String detalle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Detalle del Evento"),
          content: Text(detalle),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  // Función para crear el menú desplegable
  Widget _buildMenu(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
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
            // Opción de menú: Citaciones
            _menuItem(
              title: 'Citaciones',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClaseCitacion(widget.idUsuarioSesion,
                        widget.nombreUsuarioSesion, widget.tipoUsuarioSesion),
                  ),
                );
              },
            ),
            // Opción de menú: PQR
            _menuItem(
              title: 'PQR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClasePQR(widget.idUsuarioSesion,
                        widget.nombreUsuarioSesion, widget.tipoUsuarioSesion),
                  ),
                );
              },
            ),
            // Condicional para mostrar la opción de "Usuarios" solo para Coordinador (tipoUsuarioSesion == '1')
            if (widget.tipoUsuarioSesion == '1')
              _menuItem(
                title: 'Usuarios',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseUsuario(widget.idUsuarioSesion,
                          widget.nombreUsuarioSesion, widget.tipoUsuarioSesion),
                    ),
                  );
                },
              ),
            // Condicional para mostrar la opción de "Eventos" solo para Coordinador (tipoUsuarioSesion == '1')
            if (widget.tipoUsuarioSesion == '1')
              _menuItem(
                title: 'Eventos',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseEvento(widget.idUsuarioSesion,
                          widget.nombreUsuarioSesion, widget.tipoUsuarioSesion),
                    ),
                  );
                },
              ),
            // Condicional para mostrar la opción de "Mis Estudiantes" solo para Acudiente (tipoUsuarioSesion == '2')
            if (widget.tipoUsuarioSesion == '2')
              _menuItem(
                title: 'Mis Estudiantes',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseAcudiente(
                          widget.idUsuarioSesion, widget.tipoUsuarioSesion),
                    ),
                  );
                },
              ),
            Expanded(child: Container()),
            _menuItem(
              title: 'Cerrar sesión',
              color: Colors.red,
              onPressed: () async {
                // Lógica para cerrar sesión
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('ID');
                await prefs.remove('NOMBRES');
                await prefs.remove('CODIGOTIPOUSUARIO');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClaseLogin(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Función auxiliar para generar un ítem del menú
  Widget _menuItem(
      {required String title, required VoidCallback onPressed, Color? color}) {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      margin: const EdgeInsets.only(top: 5),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.all<Color>(color ?? Colors.blue),
        ),
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}
