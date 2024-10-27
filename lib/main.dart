import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:proyecto_grado_app/firebase_options.dart';
import 'package:proyecto_grado_app/services/bloc/notificaciones_bloc.dart';
import 'package:proyecto_grado_app/services/localNotification/local_notification.dart';
import 'package:proyecto_grado_app/vistas/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  //notificaciones en vivo
  await LocalNotification.initializeLocalNotifications();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => NotificacionesBloc()),
    ],
    child: const MainApp(),
  ));
}

//Vista principal inicio
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Cambia aquí el color principal
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: const [
        Locale('es', 'ES'), // Soporte para español
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ClaseLogin(),
    );
  }
}
//para generar apk : flutter build apk --split-per-abi
//Vista principal fin