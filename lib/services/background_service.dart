import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  static const MethodChannel _channel = MethodChannel('background_service');

  Future<bool> requestBatteryOptimizationPermission() async {
    try {
      print('DEBUG: Solicitando permissão de otimização de bateria...');
      
      // Primeiro, verificar se já temos a permissão
      final bool hasPermission = await _channel.invokeMethod('isBatteryOptimizationDisabled') ?? false;
      
      if (hasPermission) {
        print('DEBUG: App já está excluído da otimização de bateria');
        return true;
      }

      // Solicitar permissão para ignorar otimização de bateria
      final bool granted = await _channel.invokeMethod('requestBatteryOptimization') ?? false;
      
      if (granted) {
        print('DEBUG: Permissão de otimização de bateria concedida');
      } else {
        print('DEBUG: Permissão de otimização de bateria negada');
      }
      
      return granted;
    } catch (e) {
      print('DEBUG: Erro ao solicitar permissão de bateria: $e');
      return false;
    }
  }

  Future<void> showBatteryOptimizationDialog() async {
    try {
      await _channel.invokeMethod('showBatteryOptimizationDialog');
    } catch (e) {
      print('DEBUG: Erro ao mostrar diálogo de otimização: $e');
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel.invokeMethod('isBatteryOptimizationDisabled') ?? false;
    } catch (e) {
      print('DEBUG: Erro ao verificar status de otimização: $e');
      return false;
    }
  }

  Future<void> ensureBackgroundExecution() async {
    print('DEBUG: Verificando configurações de segundo plano...');
    
    // Verificar permissões de notificação
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus != PermissionStatus.granted) {
      print('DEBUG: Solicitando permissão de notificação...');
      await Permission.notification.request();
    }

    // Solicitar exclusão da otimização de bateria
    final batteryOptimization = await isIgnoringBatteryOptimizations();
    if (!batteryOptimization) {
      print('DEBUG: App não está excluído da otimização de bateria');
      await requestBatteryOptimizationPermission();
    }

    print('DEBUG: Configurações de segundo plano verificadas');
  }
}