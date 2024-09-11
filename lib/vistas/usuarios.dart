import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorUsuario.dart';
import 'package:proyecto_grado_app/vistas/usuariosGestion.dart';

class ClaseUsuario extends StatefulWidget {
  //Variables globales
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;

  const ClaseUsuario(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _UsuarioState();
}

class _UsuarioState extends State<ClaseUsuario> {
  // Lista para recibir los usuarios
  List<ConversorUsuario> listaUsuarios = [];

  //proceso init state
  @override
  void initState() {
    super.initState();
    traerUsuarios();
  }

  //Para esperar el resultado de la vista de creacion o edicion
  Future<void> NavigateAndRefresh(
      BuildContext context, String idUsuario, int valor) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaseUsuarioGestion(
          widget.idUsuarioSesion,
          widget.nombreUsuarioSesion,
          widget.tipoUsuarioSesion,
          idUsuario,
          valor,
        ),
      ),
    );
    // Volver a cargar los usuarios después de regresar
    traerUsuarios();
  }

  //funcion para la consulta de usuarios
  Future<void> traerUsuarios() async {
    final respuesta = await Dio().get('http://10.0.2.2:3000/usuario');

    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        listaUsuarios = dataList
            .map((elemento) => ConversorUsuario.fromJson(elemento))
            .toList();
      });
    }
  }

  //vista principal inicio
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Listado de usuarios"),
        ),
        body: Column(
          children: [
            _BotonConstructor(),
            Expanded(
                child:
                    _listaUsuarios()), // Aquí envolvemos el ListView en un Expanded
          ],
        ));
  }
  //vista principal fin

  //listado inicio
  Widget _listaUsuarios() {
    return ListView.builder(
      itemCount: listaUsuarios.length,
      itemBuilder: (context, index) {
        final item_usuario = listaUsuarios[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListTile(
            title: Text(
              item_usuario.nombres + ' ' + item_usuario.apellidos,
              style: const TextStyle(color: Colors.blue), // Título en azul
            ),
            subtitle: Text(item_usuario.documento.toString()),
            leading: CircleAvatar(
              backgroundColor: Colors.blue[300], // Fondo azul
              child: Text(
                item_usuario.id.toString(),
                style: const TextStyle(color: Colors.black), // Texto negro
              ),
            ),
            // Evento onTap para navegar a ClaseUsuarioGestion
            onTap: () {
              NavigateAndRefresh(context, item_usuario.id.toString(), 1);
            },
          ),
        );
      },
    );
  }

  //listado fin

  //boton inicio
  // ignore: non_constant_identifier_names
  Widget _BotonConstructor() {
    return Container(
      margin: const EdgeInsets.all(5), // Margen de 5 píxeles
      child: ElevatedButton(
        onPressed: () {
          NavigateAndRefresh(context, "0", 0);
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 20,
          minimumSize: const Size.fromHeight(60),
          foregroundColor: Colors.blue[800], // Color del texto
        ),
        child: const Text("Crear Usuario"),
      ),
    );
  }
  //boton fin
}
