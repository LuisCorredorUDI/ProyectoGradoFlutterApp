import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ClasepqrGestionDetalle extends StatefulWidget {
  final String tipoUsuarioSesion;
  final int codigoPqrConsulta;
  final int referenciaPqrConsulta;

  const ClasepqrGestionDetalle(
    this.tipoUsuarioSesion,
    this.codigoPqrConsulta,
    this.referenciaPqrConsulta, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ClasepqrGestionDetalleState();
}

class _ClasepqrGestionDetalleState extends State<ClasepqrGestionDetalle> {
  // Variables para almacenar la respuesta del API
  Map<String, dynamic>? detallePqr;
  TextEditingController respuestaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDetallePqr(widget.codigoPqrConsulta, widget.referenciaPqrConsulta);
  }

  // Método para cargar el detalle de la PQR
  Future<void> cargarDetallePqr(
      int codigoPqrConsulta, int referenciaPqrConsulta) async {
    try {
      final respuesta = await Dio().get(
        'http://10.0.2.2:3000/pqr/DetallePqr/$codigoPqrConsulta/$referenciaPqrConsulta',
      );

      if (respuesta.statusCode == 200) {
        setState(() {
          detallePqr =
              respuesta.data[0]; // Almacenar el primer objeto de la lista
          respuestaController.text = detallePqr?['RESPUESTA'] ?? '';
        });
      } else {
        _mostrarMensajeError('Error al cargar los detalles.');
      }
    } catch (e) {
      _mostrarMensajeError('Ocurrió un error inesperado.');
    }
  }

  // Método para actualizar la respuesta de la PQR
  Future<void> actualizarRespuesta(String respuesta) async {
    try {
      print(respuesta);
      await Dio().patch(
        'http://10.0.2.2:3000/pqr/ActualizarRespuesta/${widget.codigoPqrConsulta}/${widget.referenciaPqrConsulta}',
        data: {"RESPUESTA": respuesta},
      );
      _mostrarMensajeExito('Respuesta actualizada con éxito.');
      Navigator.pop(context);
    } catch (e) {
      _mostrarMensajeError('Error al actualizar la respuesta.');
    }
  }

  // Método para cancelar la PQR
  Future<void> cancelarPqr() async {
    try {
      await Dio().patch(
        'http://10.0.2.2:3000/pqr/CancelarPqr/${widget.codigoPqrConsulta}/${widget.referenciaPqrConsulta}',
      );
      _mostrarMensajeExito('PQR cancelada con éxito.');
      Navigator.pop(context);
    } catch (e) {
      _mostrarMensajeError('Error al cancelar la PQR.');
    }
  }

  // Método para mostrar un mensaje de error
  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Método para mostrar un mensaje de éxito
  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (detallePqr == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle PQR')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // Apartado 1: Número de Referencia (Campo no editable)
            _buildDetailField(
                'Número de Referencia', '${detallePqr?['NUMEROREFERENCIA']}'),

            // Apartado 2: Detalle del Usuario (Campo no editable)
            _buildDetailField('Detalle', detallePqr?['DETALLE'] ?? ''),

            // Apartado 3: Tipo de PQR (Nombre del tipo de PQR)
            _buildDetailField(
                'Tipo de PQR', detallePqr?['NOMBRETIPOPQR'] ?? ''),

            // Apartado 4: Derecho vulnerado (Solo si TIPOPQR es 1 o 2)
            if (detallePqr?['TIPOPQR'] == 1 || detallePqr?['TIPOPQR'] == 2)
              _buildDetailField(
                  'Derecho Vulnerado', detallePqr?['DERECHO'] ?? ''),

            // Apartado 5: Fecha de Creación (Formato: Año/Mes/Día Hora:Minutos)
            _buildDetailField(
                'Fecha de Creación', _formatDate(detallePqr?['FECHACREACION'])),

            // Apartado 6: Respuesta a la PQR (Campo editable según tipo de usuario)
            if (widget.tipoUsuarioSesion == '1')
              _buildEditableField('Respuesta', respuestaController)
            else
              _buildDetailField(
                  'Respuesta', detallePqr?['RESPUESTA'] ?? 'Sin Respuesta'),

            // Apartado 7: Fecha de Respuesta (Formato: Año/Mes/Día Hora:Minutos)
            _buildDetailField('Fecha de Respuesta',
                _formatDate(detallePqr?['FECHARESPUESTA'])),

            // Apartado 8: Botón de acción (Guardar o Cancelar PQR)
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  // Método para crear un campo de detalle no editable
  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          Text(value, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  // Método para crear un campo editable
  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          TextField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            maxLines: 8, // Permite múltiples líneas
          ),
        ],
      ),
    );
  }

  // Método para construir el botón de acción
  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          if (widget.tipoUsuarioSesion == '1') {
            if (respuestaController.text != '') {
              // Guardar respuesta
              actualizarRespuesta(respuestaController.text);
            } else {
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Información',
                  message: 'La respuesta al usuario, no puede estar vacía',
                  contentType: ContentType.failure,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            }
          } else {
            // Cancelar PQR
            cancelarPqr();
          }
        },
        child: Text(
            widget.tipoUsuarioSesion == '1' ? 'Guardar' : 'Cancelar PQR',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue)),
      ),
    );
  }

  // Formatear fecha (Año/Mes/Día Hora:Minutos)
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
