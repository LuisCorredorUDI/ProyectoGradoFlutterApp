import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/globales.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorDeber.dart';
import 'package:proyecto_grado_app/vistas/deberGestion.dart';

class ClaseDeber extends StatefulWidget {
  //Variables
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  // 1 - coor, 2 - acu, 3 - est
  final String tipoUsuarioSesion;

  const ClaseDeber(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _DeberState();
}

class _DeberState extends State<ClaseDeber> {
  // Variable
  List<ConversorDeber> listaDebers = [];
  String? _DeberSeleccionado;

  // Procedimiento para cargar Debers
  Future<void> traerDebers() async {
    try {
      final respuesta = await Dio()
          .get('${GlobalesClass.direccionApi}/deber/lista/DeberEstudiantes');

      if (respuesta.statusCode == 200) {
        List<dynamic> data = respuesta.data;
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          listaDebers = dataList
              .map((elemento) => ConversorDeber.fromJson(elemento))
              .toList();
          if (listaDebers.isNotEmpty) {
            _DeberSeleccionado = listaDebers.first.codigo.toString();
          }
        });
      }
    } catch (e) {
      print('Error al cargar Debers: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    traerDebers();
  }

  //Para esperar el resultado de la vista de creacion/edicion
  Future<void> NavigateAndRefresh(
      BuildContext context, int modo, String codigoDeber) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaseDeberGestion(modo, codigoDeber),
      ),
    );
    // Volver a cargar los eventos después de regresar
    traerDebers();
  }

  // Vista principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista Deber"),
      ),
      body: Column(
        children: [
          // Botón para crear Deber
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Acción para crear Deber
                NavigateAndRefresh(context, 0, '0');
              },
              child: const Text("Crear Deber",
                  style: TextStyle(color: Colors.green)),
            ),
          ),
          // Listado de Debers
          Expanded(
            child: listaDebers.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(), // Indicador de carga
                  )
                : ListView.builder(
                    itemCount: listaDebers.length,
                    itemBuilder: (context, index) {
                      final deber = listaDebers[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'Código: ${deber.codigo}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Text(
                            'Detalle: ${deber.detalle}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            NavigateAndRefresh(context, 1, '${deber.codigo}');
                          },
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
