import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StorageService _storageService = StorageService();

  // Hello Kitty themed notification messages
  static const List<String> _defaultMessages = [
    '💧 Hello Kitty te lembra: Hora de beber água! 🎀',
    '🌸 Hidrate-se com carinho! A Hello Kitty quer você saudável! 💖',
    '💧 Um copinho d\'água para manter você radiante como a Hello Kitty! ✨',
    '🎀 Sua saúde é preciosa! Beba água e brilhe! 💎',
    '💧 Hello Kitty says: Keep calm and drink water! 🌸',
    '🌺 Uma pausa fofa para se hidratar! Você merece! 💕',
    '💧 Água é vida! A Hello Kitty cuida de você! 🎀',
    '🌸 Lembrete kawaii: Hora da hidratação! 💖',
    '💧 Pequenos goles, grandes cuidados! Hello Kitty aprova! ✨',
    '🎀 Sua dose diária de carinho líquido! Beba água! 💧'
  ];

  Future<void> init() async {
    // Configuração para Android usando o ícone do kitty
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/kitty');

    // Configuração para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Você pode navegar para uma tela específica ou fazer alguma ação
    print('Notificação tocada: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    if (await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false) {
      return true;
    }

    if (await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
        false) {
      return true;
    }

    return false;
  }

  Future<void> scheduleWaterReminders() async {
    try {
      final profile = await _storageService.getUserProfile();
      if (profile?.notificationSettings.enabled != true) {
        return;
      }

      final settings = profile!.notificationSettings;
      
      // Cancelar notificações existentes
      await cancelAllNotifications();
      
      print('DEBUG: Agendando lembretes de água...');

    final startHour = int.parse(settings.startTime.split(':')[0]);
    final startMinute = int.parse(settings.startTime.split(':')[1]);
    final endHour = int.parse(settings.endTime.split(':')[0]);
    final endMinute = int.parse(settings.endTime.split(':')[1]);

    final now = DateTime.now();
    var currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      startHour,
      startMinute,
    );

    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      endHour,
      endMinute,
    );

    int notificationId = 0;
    final messages = settings.customMessages.isNotEmpty 
        ? settings.customMessages 
        : _defaultMessages;

    // Agendar notificações até o horário final
    while (currentTime.isBefore(endTime)) {
      if (currentTime.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId,
          title: '💧 Hello Kitty Water Reminder',
          body: messages[notificationId % messages.length],
          scheduledDate: currentTime,
        );
      }

      currentTime = currentTime.add(Duration(minutes: settings.frequency));
      notificationId++;
    }

    // Agendar para os próximos dias (próximos 7 dias)
    for (int day = 1; day <= 7; day++) {
      var dayStartTime = DateTime(
        now.year,
        now.month,
        now.day + day,
        startHour,
        startMinute,
      );

      final dayEndTime = DateTime(
        now.year,
        now.month,
        now.day + day,
        endHour,
        endMinute,
      );

      while (dayStartTime.isBefore(dayEndTime)) {
        await _scheduleNotification(
          id: notificationId,
          title: '💧 Hello Kitty Water Reminder',
          body: messages[notificationId % messages.length],
          scheduledDate: dayStartTime,
        );

        dayStartTime = dayStartTime.add(Duration(minutes: settings.frequency));
        notificationId++;

        // Limite de notificações para evitar muitas
        if (notificationId > 200) break;
      }
      
      if (notificationId > 200) break;
    }
    
    print('DEBUG: Lembretes agendados com sucesso!');
    } catch (e) {
      print('DEBUG: Erro ao agendar lembretes: $e');
      // Se falhar com alarmes exatos, tentar sem eles
      rethrow;
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_reminder',
      'Water Reminders',
      channelDescription: 'Notificações para lembrar de beber água',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/kitty',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);
      print('DEBUG: Agendando notificação $id para: $scheduledTz');
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'water_reminder',
      );
      
      print('DEBUG: Notificação $id agendada com sucesso!');
    } catch (e) {
      print('DEBUG: Erro ao agendar notificação $id: $e');
      // Fallback: tentar com agendamento menos restritivo
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'water_reminder',
        );
        print('DEBUG: Notificação $id agendada com fallback!');
      } catch (e2) {
        print('DEBUG: Falha total ao agendar notificação $id: $e2');
      }
    }
  }

  Future<void> showInstantReminder([String? customMessage]) async {
    print('DEBUG: Tentando mostrar notificação instantânea...');
    
    // Primeiro, solicitar permissões se necessário
    final permissionGranted = await requestPermissions();
    print('DEBUG: Permissão concedida: $permissionGranted');
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_reminder',
      'Lembrete Instantâneo',
      channelDescription: 'Lembrete imediato para beber água',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/kitty',
      playSound: true,
      enableVibration: true,
      ticker: 'Lembrete da Hello Kitty',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        999, // ID fixo para lembrete instantâneo
        '💧 Lembrete da Kitty',
        customMessage ?? 'Hora de beber água! 🎀💖',
        platformChannelSpecifics,
        payload: 'instant_reminder',
      );
      print('DEBUG: Notificação enviada com sucesso!');
    } catch (e) {
      print('DEBUG: Erro ao enviar notificação: $e');
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> testNotifications() async {
    print('DEBUG: Testando sistema de notificações...');
    
    // Testar permissões
    final hasPermission = await requestPermissions();
    print('DEBUG: Permissão de notificação: $hasPermission');
    
    if (!hasPermission) {
      print('DEBUG: ERRO - Sem permissão para notificações!');
      return;
    }

    // Testar notificação instantânea
    await showInstantReminder('🧪 Teste: Notificações funcionando! 🎀');
    
    // Agendar uma notificação de teste em 1 minuto
    final testTime = DateTime.now().add(const Duration(minutes: 1));
    await _scheduleNotification(
      id: 9999,
      title: '🧪 Teste Agendado',
      body: 'Esta notificação foi agendada para teste! 🎀',
      scheduledDate: testTime,
    );
    
    // Verificar notificações pendentes
    final pending = await getPendingNotifications();
    print('DEBUG: ${pending.length} notificações pendentes:');
    for (final notification in pending) {
      print('  - ID ${notification.id}: ${notification.title} (${notification.body})');
    }
  }
}