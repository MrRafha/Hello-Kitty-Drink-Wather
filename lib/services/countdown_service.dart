import 'dart:async';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class CountdownService extends ChangeNotifier {
  static final CountdownService _instance = CountdownService._internal();
  factory CountdownService() => _instance;
  CountdownService._internal();

  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  int _totalSeconds = 0;
  bool _isActive = false;
  bool _isInitialized = false;
  
  // Getters
  int get secondsRemaining => _secondsRemaining;
  int get totalSeconds => _totalSeconds;
  bool get isActive => _isActive;
  bool get isInitialized => _isInitialized;
  
  double get progress => _totalSeconds > 0 ? (_totalSeconds - _secondsRemaining) / _totalSeconds : 0.0;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('DEBUG: Inicializando CountdownService...');
      await _loadCountdownSettings();
      _isInitialized = true;
      print('DEBUG: CountdownService inicializado com sucesso');
    } catch (e) {
      print('DEBUG: Erro ao inicializar CountdownService: $e');
    }
  }

  Future<void> _loadCountdownSettings() async {
    try {
      final profile = await _storageService.getUserProfile();
      if (profile?.notificationSettings.enabled == true) {
        final frequencyMinutes = profile!.notificationSettings.frequency;
        _totalSeconds = frequencyMinutes * 60;
        
        // Se já estava rodando, manter o tempo restante
        if (!_isActive || _secondsRemaining <= 0) {
          _secondsRemaining = _totalSeconds;
        }
        
        _isActive = true;
        _startCountdown();
        print('DEBUG: Countdown configurado para ${frequencyMinutes} minutos ($_totalSeconds segundos)');
      } else {
        _stopCountdown();
        print('DEBUG: Notificações desabilitadas - countdown parado');
      }
      notifyListeners();
    } catch (e) {
      print('DEBUG: Erro ao carregar configurações do countdown: $e');
    }
  }

  void _startCountdown() {
    // Não reiniciar se já está rodando
    if (_countdownTimer?.isActive == true) {
      print('DEBUG: Countdown já está ativo');
      return;
    }
    
    _countdownTimer?.cancel();
    
    if (!_isActive || _secondsRemaining <= 0) {
      print('DEBUG: Countdown não ativo ou tempo zerado');
      return;
    }

    print('DEBUG: Iniciando countdown com $_secondsRemaining segundos restantes');
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
        
        // Log apenas a cada 30 segundos para não poluir
        if (_secondsRemaining % 30 == 0) {
          print('DEBUG: Countdown: ${_formatTime(_secondsRemaining)} restantes');
        }
      } else {
        _onCountdownComplete();
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _isActive = false;
    notifyListeners();
    print('DEBUG: Countdown parado');
  }

  Future<void> _onCountdownComplete() async {
    print('DEBUG: Countdown completado! Enviando notificação...');
    
    _countdownTimer?.cancel();
    
    try {
      // Enviar notificação
      await _notificationService.showInstantReminder('💧 Hora de beber água! A Hello Kitty te lembra! 🎀');
      print('DEBUG: Notificação enviada com sucesso');
    } catch (e) {
      print('DEBUG: Erro ao enviar notificação: $e');
    }
    
    // Reiniciar countdown
    _secondsRemaining = _totalSeconds;
    notifyListeners();
    
    // Aguardar um pouco antes de reiniciar
    await Future.delayed(const Duration(seconds: 1));
    _startCountdown();
    
    print('DEBUG: Countdown reiniciado');
  }

  void resetCountdown() {
    print('DEBUG: Reset manual do countdown');
    _secondsRemaining = _totalSeconds;
    notifyListeners();
    _startCountdown();
  }

  Future<void> updateSettings() async {
    print('DEBUG: Atualizando configurações do countdown...');
    await _loadCountdownSettings();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  String get formattedTime => _formatTime(_secondsRemaining);
  
  String get statusMessage {
    if (!_isActive) return 'Notificações desabilitadas';
    if (_secondsRemaining > 60) {
      return 'Faltam ${(_secondsRemaining / 60).ceil()} minutos para o próximo lembrete';
    } else if (_secondsRemaining > 0) {
      return 'Menos de 1 minuto para o próximo lembrete! 💧';
    } else {
      return 'Enviando lembrete...';
    }
  }

  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}