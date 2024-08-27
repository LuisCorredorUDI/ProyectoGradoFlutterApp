//Vista Home inicio
import 'package:flutter/material.dart';
import 'package:proyecto_grado_app/vistas/Observador.dart';
import 'package:proyecto_grado_app/vistas/citaciones.dart';
import 'package:proyecto_grado_app/vistas/pqr.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("AGE App"),
      ),
      body: const Center(
        child: Text('Hello World!'),
      ),
    );
  }
}
//Vista Home fin

//Vista Menu Desplegable
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
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
              child: Image.network(
                  "https://e7.pngegg.com/pngimages/178/595/png-clipart-user-profile-computer-icons-login-user-avatars-monochrome-black-thumbnail.png"),
            ),
            const Text(
              "Nombre Usuario",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  color: Colors.indigo),
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
                      builder: (context) => ClaseObservador("1", "Luis", "1"),
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
                // Cambio de vista
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaseCitaciones("1", "Luis", "1"),
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
                      builder: (context) => ClasePQR("1", "Luis", "1"),
                    ),
                  );
                },
                child: const Text('PQR'),
              ),
            ),
            Expanded(child: Container()),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {},
                child: const Text('Cerrar sesión'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
//Vista Menu Desplegable
