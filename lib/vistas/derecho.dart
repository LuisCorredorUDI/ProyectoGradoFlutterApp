import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/globales.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorDerecho.dart';
import 'package:proyecto_grado_app/vistas/derechoGestion.dart';

class ClaseDerecho extends StatefulWidget {
  //Variables
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  // 1 - coor, 2 - acu, 3 - est
  final String tipoUsuarioSesion;

  const ClaseDerecho(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {super.key});

  @override
  State<StatefulWidget> createState() => _DerechoState();
}

class _DerechoState extends State<ClaseDerecho> {
  // Variable
  List<ConversorDerecho> listaDerechos = [];
  String? _derechoSeleccionado;

  // Procedimiento para cargar derechos
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

  @override
  void initState() {
    super.initState();
    traerderechos();
  }

  //Para esperar el resultado de la vista de creacion/edicion
  Future<void> NavigateAndRefresh(
      BuildContext context, int modo, String codigoDerecho) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaseDerechoGestion(modo, codigoDerecho),
      ),
    );
    // Volver a cargar los eventos después de regresar
    traerderechos();
  }

  // Vista principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista Derecho"),
      ),
      body: Column(
        children: [
          // Botón para crear derecho
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Acción para crear derecho
                NavigateAndRefresh(context, 0, '0');
              },
              child: const Text("Crear Derecho",
                  style: TextStyle(color: Colors.green)),
            ),
          ),
          // Listado de derechos
          Expanded(
            child: listaDerechos.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(), // Indicador de carga
                  )
                : ListView.builder(
                    itemCount: listaDerechos.length,
                    itemBuilder: (context, index) {
                      final derecho = listaDerechos[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'Código: ${derecho.codigo}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Text(
                            'Detalle: ${derecho.detalle}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            NavigateAndRefresh(context, 1, '${derecho.codigo}');
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
