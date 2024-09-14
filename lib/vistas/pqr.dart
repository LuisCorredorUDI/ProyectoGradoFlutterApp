import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/Conversores/conversorPqr.dart';
import 'package:proyecto_grado_app/vistas/pqrGestion.dart';
import 'package:proyecto_grado_app/vistas/pqrGestionDetalle.dart';

class ClasePQR extends StatefulWidget {
  final String idUsuarioSesion;
  final String nombreUsuarioSesion;
  final String tipoUsuarioSesion;

  const ClasePQR(
      this.idUsuarioSesion, this.nombreUsuarioSesion, this.tipoUsuarioSesion,
      {Key? key})
      : super(key: key);

  @override
  _ClasePQRState createState() => _ClasePQRState();
}

class _ClasePQRState extends State<ClasePQR> {
  // Variable para almacenar el estado del filtro
  String filtroSeleccionado = 'Todas';

  //Lista para recibir las pqr
  List<ConversorPqr> listapqr = [];

  // Lista simulada de PQRs
  List<String> pqrList = [];

  //Para esperar el resultado de la vista de creacion
  Future<void> NavigateAndRefresh(
      BuildContext context, String codigoPqr, int modo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClasePqrGestion(widget.idUsuarioSesion,
            widget.nombreUsuarioSesion, widget.tipoUsuarioSesion, codigoPqr),
      ),
    );
    // Volver a cargar los usuarios después de regresar
    filtroSeleccionado = 'Todas';
    cargarPqr(widget.idUsuarioSesion, widget.tipoUsuarioSesion, 'Todas');
  }

  //Para definir quien necesita ver el detalle, si el coordinador para dar respuesta
  //o el usuario para consultar
  Future<void> CargarDetallePqr(int codigo, int numeroReferencia) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClasepqrGestionDetalle(
            widget.tipoUsuarioSesion, codigo, numeroReferencia),
      ),
    );
    // Volver a cargar los usuarios después de regresar
    filtroSeleccionado = 'Todas';
    cargarPqr(widget.idUsuarioSesion, widget.tipoUsuarioSesion, 'Todas');
  }

  // Método para cargar la lista de PQRs
  Future<void> cargarPqr(
      String idUsuarioSesion, String tipoUsuarioSesion, String filtro) async {
    // Variable para la ruta de consulta
    String ruta = '';

    try {
      if (filtro == 'Todas') {
        // Coordinador Todas
        if (tipoUsuarioSesion == '1') {
          ruta = 'http://10.0.2.2:3000/pqr/PorCoordinadorTodas';
        } else // Est-Acu Todas
        {
          ruta = 'http://10.0.2.2:3000/pqr/PorUsuarioTodas/$idUsuarioSesion';
        }
      } else if (filtro == 'En revision') {
        // Coordinador Revision
        if (tipoUsuarioSesion == '1') {
          ruta = 'http://10.0.2.2:3000/pqr/PorCoordinadorSinRevisar';
        } else // Est-Acu Revision
        {
          ruta =
              'http://10.0.2.2:3000/pqr/PorUsuarioSinRevisar/$idUsuarioSesion';
        }
      } else if (filtro == 'Revisadas') {
        // Coordinador revisadas
        if (tipoUsuarioSesion == '1') {
          ruta = 'http://10.0.2.2:3000/pqr/PorCoordinadorRevisadas';
        } else // Est-Acu revisadas
        {
          ruta =
              'http://10.0.2.2:3000/pqr/PorUsuarioRevisadas/$idUsuarioSesion';
        }
      }

      // Petición al API
      final respuesta = await Dio().get(ruta);

      if (respuesta.statusCode == 200) {
        List<dynamic> data = respuesta.data;
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          listapqr = dataList
              .map((elemento) => ConversorPqr.fromJson(elemento))
              .toList();
        });
      } else {
        // Manejo de códigos de estado HTTP diferentes a 200
        _mostrarMensajeError(
            'Error: ${respuesta.statusCode} - ${respuesta.statusMessage}');
      }
    } on DioError catch (e) {
      // Manejo de errores específicos de Dio
      if (e.type == DioErrorType.connectionTimeout) {
        _mostrarMensajeError('Tiempo de conexión agotado. Inténtalo de nuevo.');
      } else if (e.type == DioErrorType.receiveTimeout) {
        _mostrarMensajeError(
            'El servidor tardó demasiado en responder. Inténtalo más tarde.');
      } else if (e.type == DioErrorType.badResponse) {
        _mostrarMensajeError(
            'Error en la respuesta del servidor: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      } else {
        _mostrarMensajeError('Error de conexión. Verifica tu red.');
      }
    } catch (e) {
      // Manejo de cualquier otro tipo de excepción
      _mostrarMensajeError('Ocurrió un error inesperado: $e');
    }
  }

// Método para mostrar mensajes de error
  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Cargar la lista de PQRs al inicio
    cargarPqr(
        widget.idUsuarioSesion, widget.tipoUsuarioSesion, filtroSeleccionado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado Pqr'),
      ),
      body: Column(
        children: [
          // Fila de botones (Crear PQR y Refrescar)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.tipoUsuarioSesion == '2' ||
                    widget.tipoUsuarioSesion == '3')
                  _buildCrearPqrButton(), // Botón "Crear Pqr"
              ],
            ),
          ),
          // Widget tipo Checkbox (filtro de PQRs)
          _buildFiltroPqrOptions(),
          // Lista de PQRs cargadas
          _buildPqrList(),
        ],
      ),
    );
  }

// Widget Botón "Crear Pqr"
  Widget _buildCrearPqrButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Lógica para crear PQR
        NavigateAndRefresh(this.context, "0", 0);
      },
      icon: const Icon(
        Icons.add,
        color: Colors.green,
      ),
      label: const Text(
        'Crear Pqr',
        style: TextStyle(color: Colors.green),
      ),
    );
  }

// Widget para los filtros de PQRs (tipo checkbox)
  Widget _buildFiltroPqrOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRadioOption('En revision'),
        _buildRadioOption('Revisadas'),
        _buildRadioOption('Todas'),
      ],
    );
  }

// Widget Lista de PQRs cargadas
  Widget _buildPqrList() {
    return Expanded(
      child: ListView.builder(
        itemCount: listapqr.length,
        itemBuilder: (context, index) {
          final pqr = listapqr[index];
          return _buildPqrCard(pqr);
        },
      ),
    );
  }

// Widget para una tarjeta individual de PQR
  Widget _buildPqrCard(ConversorPqr pqr) {
    // Determinar color y texto de gravedad
    Color gravedadColor = _getGravedadColor(pqr.nombreGravedadtipopqr);

    // Determinar el texto del estado
    String estadoTexto = _getEstadoTexto(pqr.estadopqr);

    // Formatear la fecha en AÑO/MES/DIA
    String formattedFechaCreacion =
        "${pqr.fechacreacion.year}/${pqr.fechacreacion.month.toString().padLeft(2, '0')}/${pqr.fechacreacion.day.toString().padLeft(2, '0')}";

    return InkWell(
      onTap: () {
        CargarDetallePqr(pqr.codigo, pqr.numeroreferencia);
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        color: Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Número de Referencia:', '${pqr.numeroreferencia}'),
              const SizedBox(height: 3),
              _buildInfoRowWithColumns(
                'Fecha de Creación:',
                formattedFechaCreacion,
                'Tipo de PQR:',
                pqr.nombretipopqr,
              ),
              const SizedBox(height: 3),
              _buildInfoRowWithColumns(
                'Gravedad:',
                pqr.nombreGravedadtipopqr,
                'Estado:',
                estadoTexto,
                gravedadColor: gravedadColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Método para construir una fila de información con dos columnas
  Widget _buildInfoRowWithColumns(
      String label1, String value1, String label2, String value2,
      {Color gravedadColor = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label1,
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              value1,
              style: TextStyle(color: gravedadColor),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label2,
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              value2,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

// Método para construir una fila de información
  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontStyle: FontStyle.italic,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

// Obtener el color basado en la gravedad
  Color _getGravedadColor(String gravedad) {
    switch (gravedad) {
      case 'Media':
        return Colors.orange;
      case 'Alta':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

// Obtener el texto del estado basado en el código de estado
  String _getEstadoTexto(int estado) {
    switch (estado) {
      case 0:
        return 'Sin Revisar';
      case 1:
        return 'Revisada';
      case 2:
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
  }

  // Widget helper para crear las opciones de radio button inicio
  Widget _buildRadioOption(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: filtroSeleccionado,
          onChanged: (String? newValue) {
            setState(() {
              filtroSeleccionado = newValue!;
              // Refrescar la lista de PQRs al cambiar el filtro
              cargarPqr(widget.idUsuarioSesion, widget.tipoUsuarioSesion,
                  filtroSeleccionado);
            });
          },
        ),
        Text(value),
      ],
    );
  }
  // Widget helper para crear las opciones de radio button fin
}
