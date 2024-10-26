import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorUsuario.dart';
import 'package:proyecto_grado_app/vistas/usuariosGestion.dart';
import 'package:proyecto_grado_app/globales.dart';

class ClaseUsuario extends StatefulWidget {
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
  // Lista completa de usuarios
  List<ConversorUsuario> listaUsuarios = [];
  // Lista filtrada de usuarios
  List<ConversorUsuario> listaFiltrada = [];

  // Controlador para el campo de búsqueda
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    traerUsuarios();

    // Escuchar cambios en el texto de búsqueda
    _searchController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para filtrar usuarios según el texto de búsqueda
  void _filtrarUsuarios() {
    String textoBusqueda = _searchController.text.toLowerCase();

    setState(() {
      listaFiltrada = listaUsuarios.where((usuario) {
        return usuario.nombres.toLowerCase().contains(textoBusqueda);
      }).toList();
    });
  }

  // Para esperar el resultado de la vista de creación o edición
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

  // Función para la consulta de usuarios
  Future<void> traerUsuarios() async {
    final respuesta = await Dio().get('${GlobalesClass.direccionApi}/usuario');

    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        listaUsuarios = dataList
            .map((elemento) => ConversorUsuario.fromJson(elemento))
            .toList();
        listaFiltrada = listaUsuarios; // Inicialmente, todos los usuarios
      });
    }
  }

  // Vista principal inicio
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de usuarios"),
      ),
      body: Column(
        children: [
          _BotonConstructor(),
          _CajaBusqueda(), // Caja de texto para buscar usuarios
          Expanded(child: _listaUsuarios()), // Lista de usuarios filtrados
        ],
      ),
    );
  }

  // Caja de texto para buscar usuarios
  Widget _CajaBusqueda() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Buscar usuario por nombre',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  // Listado de usuarios
  Widget _listaUsuarios() {
    return ListView.builder(
      itemCount: listaFiltrada.length,
      itemBuilder: (context, index) {
        final item_usuario = listaFiltrada[index];
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
            onTap: () {
              NavigateAndRefresh(context, item_usuario.id.toString(), 1);
            },
          ),
        );
      },
    );
  }

  // Botón para crear usuarios
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
}
