import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:proyecto_grado_app/services/localNotification/local_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notificaciones_event.dart';
part 'notificaciones_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  var mensaje = message.data;
  var title = mensaje['title'];
  var body = mensaje['body'];
  Random random = Random();
  var id = random.nextInt(100000);
  LocalNotification.showLocalNotification(id: id, title: title, body: body);
}

class NotificacionesBloc
    extends Bloc<NotificacionesEvent, NotificacionesState> {
  //instancia de firebase messagin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificacionesBloc() : super(NotificacionesInitial()) {
    _onForegroundMessage();
  }

  //Metodo para pedir permiso para notificaciones inicio
  void pedirPermisosUsuario() async {
    print('-');
    print('-');
    print('al menos paso');
    print('-');
    print('-');
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true);
    await LocalNotification.requestPermissionLocalNotifications();
    settings.authorizationStatus;
    _generarToken();
  }
  //Metodo para pedir permiso para notificaciones fin

  //Metodo para obtener el token -  inicio
  void _generarToken() async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    if (token != null) {
      //se guarda el token en las preferencias
      print('Token generado : ' + token);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('TOKEN', token);
    }
  }
  //Metodo para obtener el token - fin

  //Metodo para escuchar los mesajes - inicio
  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(manejadorMensajesRemotos);
  }
  //Metodo para escuchar los mesajes - fin

  //Para mostrar la  notificacion en pantalla - inicio
  void manejadorMensajesRemotos(RemoteMessage message) {
    print(message.data);
    var mensaje = message.data;
    var title = mensaje['title'];
    var body = mensaje['body'];
    print(title);
    print(body);
    Random random = Random();
    var id = random.nextInt(100000);
    LocalNotification.showLocalNotification(id: id, title: title, body: body);
  }
  //Para mostrar la  notificacion en pantalla - fin
}
