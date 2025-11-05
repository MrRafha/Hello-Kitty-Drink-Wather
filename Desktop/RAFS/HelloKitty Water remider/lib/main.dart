import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'theme/hello_kitty_theme.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/countdown_service.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Inicializar serviços
  await StorageService().init();
  await NotificationService().init();
  await CountdownService().initialize();
  
  // Solicitar permissões de notificação
  await NotificationService().requestPermissions();
  
  // Configurar orientação da tela
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const HelloKittyWaterReminderApp());
}

class HelloKittyWaterReminderApp extends StatelessWidget {
  const HelloKittyWaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Kitty Water Reminder',
      debugShowCheckedModeBanner: false,
      theme: HelloKittyTheme.lightTheme,
      home: const HelloKittyWaterApp(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Previne zoom de texto
          ),
          child: child!,
        );
      },
    );
  }
}