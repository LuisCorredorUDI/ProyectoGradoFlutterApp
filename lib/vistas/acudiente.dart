import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorUsuario.dart';
import 'package:proyecto_grado_app/vistas/citacionGestion.dart';
import 'package:proyecto_grado_app/globales.dart';

class ClaseAcudiente extends StatefulWidget {
  //Acudiente al que vamos a gestionar
  final String idUsuarioConsulta;
  //Usuario que esta en la sesion
  // 1 - coor, 2 - acu, 3 - est
  final String tipoUsuarioSesion;

  const ClaseAcudiente(this.idUsuarioConsulta, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _AcudienteState();
}

class _AcudienteState extends State<ClaseAcudiente> {
  // Lista completa de usuarios
  List<ConversorUsuario> listaEstudiantes = [];
  // Lista filtrada de usuarios
  List<ConversorUsuario> listaFiltrada = [];
  // Lista completa de usuarios
  List<ConversorUsuario> listaEstudiantesVinculados = [];

  // Controlador para el campo de búsqueda
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    traerEstudiantes();
    traerEstudiantesVinculados();
    // Escuchar cambios en el texto de búsqueda
    _searchController.addListener(_filtrarEstudiantes);
    print(widget.idUsuarioConsulta);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para filtrar usuarios según el texto de búsqueda
  void _filtrarEstudiantes() {
    String textoBusqueda = _searchController.text.toLowerCase();

    setState(() {
      listaFiltrada = listaEstudiantes.where((usuario) {
        return usuario.nombres.toLowerCase().contains(textoBusqueda);
      }).toList();
    });
  }

  // Función para la consulta de estudiantes por vincular
  Future<void> traerEstudiantes() async {
    final respuesta = await Dio()
        .get('${GlobalesClass.direccionApi}/usuario/ListadoPorVincular/');

    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        listaEstudiantes = dataList
            .map((elemento) => ConversorUsuario.fromJson(elemento))
            .toList();
        listaFiltrada = listaEstudiantes; // Inicialmente, todos los usuarios
      });
    }
  }

  // Función para la consulta de estudiantes vinculados
  Future<void> traerEstudiantesVinculados() async {
    final respuesta = await Dio().get(
        '${GlobalesClass.direccionApi}/usuario/ListadoVinculados/Acudiente/' +
            widget.idUsuarioConsulta);

    if (respuesta.statusCode == 200) {
      List<dynamic> data = respuesta.data;
      List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        listaEstudiantesVinculados = dataList
            .map((elemento) => ConversorUsuario.fromJson(elemento))
            .toList();
      });
    }
  }

  //funcion para vincular un estudiante a un acudiente
  Future<bool> vincularEstudiante(int idEstudiante) async {
    try {
      final respuesta = await Dio().post(
          '${GlobalesClass.direccionApi}/usuario/CrearAcudiente/${widget.idUsuarioConsulta}/${idEstudiante}');
      // Verificamos si la respuesta fue exitosa (código 200)
      if (respuesta.statusCode == 200) {
        print('Acudiente Creado exitosamente: ${respuesta.data.toString()}');
        return true;
      } else {
        print('Error al Crear Acudiente: ${respuesta.data.toString()}');
        return false;
      }
    } catch (error) {
      print('Error al Crear Acudiente: ${error.toString()}');
      return false;
    }
  }

  //funcion para vincular un estudiante a un acudiente
  Future<bool> desvincularEstudiante(int idEstudiante) async {
    try {
      final respuesta = await Dio().delete(
          '${GlobalesClass.direccionApi}/usuario/DesvincularAcudiente/${widget.idUsuarioConsulta}/${idEstudiante}');
      // Verificamos si la respuesta fue exitosa (código 200)
      if (respuesta.statusCode == 200) {
        print('Desvinculacion exitosamente: ${respuesta.data.toString()}');
        return true;
      } else {
        print('Error al Desvincular: ${respuesta.data.toString()}');
        return false;
      }
    } catch (error) {
      print('Error al Desvincular: ${error.toString()}');
      return false;
    }
  }

  // Para esperar el resultado de la vista de creación de citaciones
  Future<void> citarAcudiente(BuildContext context, int idEstudiante) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaseCitacionGestion(widget.idUsuarioConsulta,
            idEstudiante.toString(), widget.tipoUsuarioSesion),
      ),
    );
  }

  // Vista principal inicio
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estudiantes"),
      ),
      body: Column(
        children: [
          Text(
            'Estudiantes vinculados',
            style: TextStyle(color: Colors.blue[800]),
          ),
          if (listaEstudiantesVinculados.isNotEmpty)
            if (widget.tipoUsuarioSesion == '2')
              Expanded(child: _listaEstudiantesVinculadosSoloVista())
            else
              Expanded(child: _listaEstudiantesVinculados())
          else
            Text(
              'Este acudiente no está vinculado a ningún estudiante.',
              style: TextStyle(color: Colors.red[800]),
            ),
          if (widget.tipoUsuarioSesion == '1') ...[
            Text(
              'Estudiantes por vincular',
              style: TextStyle(color: Colors.green[800]),
            ),
            _CajaBusqueda(), // Caja de texto para buscar usuarios
            Expanded(child: _listaEstudiantes()), // Lista de usuarios filtrados
          ]
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
  Widget _listaEstudiantes() {
    return ListView.builder(
      itemCount: listaFiltrada.length,
      itemBuilder: (context, index) {
        final item_usuario = listaFiltrada[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListTile(
            title: Text(
              '${item_usuario.nombres} ${item_usuario.apellidos}',
              style: const TextStyle(color: Colors.blue), // Título en azul
            ),
            subtitle: Text(item_usuario.documento.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.add), // Icono +
              color: Colors.blue,
              onPressed: () async {
                if (await vincularEstudiante(item_usuario.id)) {
                  final snackBar = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Información',
                      message: 'Estudiante vinculado de forma correcta',
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
                      message: 'No se pudo vincular el estudiante.',
                      contentType: ContentType.failure,
                    ),
                  );

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                  Navigator.pop(context);
                }
                //print(item_usuario.id); // Imprime el id en consola
              },
            ),
          ),
        );
      },
    );
  }

// Listado de estudiantes vinculados
  Widget _listaEstudiantesVinculados() {
    return ListView.builder(
      itemCount: listaEstudiantesVinculados.length,
      itemBuilder: (context, index) {
        final item_usuario = listaEstudiantesVinculados[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: ListTile(
            title: Text(
              '${item_usuario.nombres} ${item_usuario.apellidos}',
              style: const TextStyle(color: Colors.blue), // Título en azul
            ),
            subtitle: Text(item_usuario.documento.toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Para ajustar el tamaño del Row
              children: [
                // Botón de la campana de notificaciones
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Color de fondo
                    shape: BoxShape.circle, // Botón circular
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications), // Icono de campana
                    color: Colors.blue, // Color del icono
                    onPressed: () async {
                      citarAcudiente(context, item_usuario.id);
                    },
                  ),
                ),
                const SizedBox(width: 10), // Espacio entre los botones
                // Botón de eliminar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Color de fondo
                    shape: BoxShape.circle, // Botón circular
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove), // Icono de eliminar
                    color: Colors.blue,
                    onPressed: () async {
                      if (await desvincularEstudiante(item_usuario.id)) {
                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Información',
                            message:
                                'Estudiante Desvinculado de forma correcta',
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
                            message: 'No se pudo desvincular el estudiante.',
                            contentType: ContentType.failure,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Listado de estudiantes vinculados
  Widget _listaEstudiantesVinculadosSoloVista() {
    return ListView.builder(
      itemCount: listaEstudiantesVinculados.length,
      itemBuilder: (context, index) {
        final item_usuario = listaEstudiantesVinculados[index];
        return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Column(
              children: [
                Text('Nombre:'),
                Text(
                  '${item_usuario.nombres} ${item_usuario.apellidos}',
                  style: const TextStyle(color: Colors.blue), // Título en azul
                ),
                Text('Documento:'),
                Text('${item_usuario.documento}',
                    style: const TextStyle(color: Colors.blue)),
                Text('Contacto:'),
                Text('${item_usuario.numeromovil}',
                    style: const TextStyle(color: Colors.blue)),
              ],
            ));
      },
    );
  }

//fin state
}
