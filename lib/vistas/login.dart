import 'package:flutter/material.dart';

class ClaseLogin extends StatefulWidget {
  const ClaseLogin({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<ClaseLogin> {
  TextEditingController controladorDocumento = TextEditingController();
  TextEditingController controladorClave = TextEditingController();

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
}

// Formulario
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
Widget _InputFieldsConstructor(
    TextEditingController controlador, String hintText,
    {bool esClave = false}) {
  return TextField(
    controller: controlador,
    style: TextStyle(color: Colors.white),
    cursorColor: Colors.white,
    decoration: InputDecoration(
      suffixIcon: esClave
          ? Icon(
              Icons.remove_red_eye,
              color: Colors.white,
            )
          : Icon(Icons.done, color: Colors.white),
      hintText: hintText, // Texto de sugerencia
      hintStyle: TextStyle(color: Colors.white70),
      focusedBorder: UnderlineInputBorder(
        borderSide:
            BorderSide(color: Colors.white), // Borde cuando está enfocado
      ),
    ),
    obscureText: esClave,
  );
}

// Botón
Widget _BotonConstructor() {
  return Container(
    margin: const EdgeInsets.all(5), // Margen de 5 píxeles
    child: ElevatedButton(
      onPressed: () {},
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
