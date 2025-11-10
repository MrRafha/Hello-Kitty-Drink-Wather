import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/water_models.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/water_counter_widget.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/water_reminder_countdown.dart';
import '../widgets/streak_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  int _currentGlasses = 0;
  int _dailyGoal = 8;
  UserProfile? _userProfile;
  HydrationStreak _hydrationStreak = HydrationStreak();
  DateTime? _lastCheckedDate;
  
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
    _startPeriodicStreakCheck();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _startPeriodicStreakCheck() {
    // Verificar o streak a cada 30 segundos para detectar mudança de dia
    Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Se o dia mudou, verificar o streak do dia anterior
      if (_lastCheckedDate != null && _lastCheckedDate!.isBefore(today)) {
        _checkStreakForPreviousDay();
      }
      
      _lastCheckedDate = today;
    });
    
    // Definir a data inicial
    final now = DateTime.now();
    _lastCheckedDate = DateTime(now.year, now.month, now.day);
  }

  Future<void> _checkStreakForPreviousDay() async {
    try {
      // Verificar se o streak foi quebrado ontem
      await _storageService.checkStreakAtEndOfDay(_currentGlasses, _dailyGoal);
      
      // Recarregar dados atualizados
      final updatedStreak = await _storageService.getHydrationStreak();
      setState(() {
        _hydrationStreak = updatedStreak;
      });
    } catch (e) {
      print('Erro ao verificar streak do dia anterior: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final todayIntake = await _storageService.getTodayIntake();
      final profile = await _storageService.getUserProfile() ?? 
          _storageService.getDefaultProfile();
      
      // Verificar e atualizar streak diariamente
      await _storageService.checkAndUpdateStreakDaily();
      final streak = await _storageService.getHydrationStreak();

      setState(() {
        _currentGlasses = todayIntake;
        _dailyGoal = profile.dailyGoal.glasses;
        _userProfile = profile;
        _hydrationStreak = streak;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  Future<void> _addWater({int glasses = 1}) async {
    try {
      print('DEBUG: Adicionando $glasses copos. Contador atual: $_currentGlasses');
      
      final oldGlasses = _currentGlasses;
      
      // Adicionar água ao storage primeiro
      await _storageService.addWaterGlass(glasses: glasses);
      
      // Atualizar o estado após confirmar a persistência
      setState(() {
        _currentGlasses += glasses;
      });
      
      print('DEBUG: Água adicionada com sucesso - Antes: $oldGlasses, Agora: $_currentGlasses');
      
      // Vibração e animação de celebração
      HapticFeedback.lightImpact();
      
      // Se atingiu a meta pela primeira vez hoje
      if (oldGlasses < _dailyGoal && _currentGlasses >= _dailyGoal) {
        _celebrateGoalAchieved();
        // Atualizar streak
        await _updateStreakForGoal();
      }
      
    } catch (e) {
      _showErrorSnackBar('Erro ao adicionar água: $e');
    }
  }

  void _celebrateGoalAchieved() {
    _celebrationController.forward().then((_) {
      _celebrationController.reset();
    });
    
    HapticFeedback.mediumImpact();
    _notificationService.showInstantReminder(
      '🎉 Parabéns! Você atingiu sua meta diária! A Kitty está orgulhosa! 💖',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('🎉 Meta atingida! A Kitty está orgulhosa! 💖'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _updateStreakForGoal() async {
    try {
      await _storageService.updateStreakForGoalAchieved(_currentGlasses, _dailyGoal);
      
      // Recarregar o streak atualizado
      final updatedStreak = await _storageService.getHydrationStreak();
      
      setState(() {
        _hydrationStreak = updatedStreak;
      });
      
      // Mostrar celebração de streak se for significativo
      if (updatedStreak.currentStreak >= 3) {
        _showStreakCelebration(updatedStreak);
      }
    } catch (e) {
      print('Erro ao atualizar streak: $e');
    }
  }

  void _showStreakCelebration(HydrationStreak streak) {
    final isNewRecord = streak.currentStreak == streak.longestStreak && streak.currentStreak > 1;
    
    showDialog(
      context: context,
      builder: (context) => StreakCelebrationDialog(
        newStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
        isNewRecord: isNewRecord,
      ),
    );
  }

  void _showStreakInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🔥 Sua Sequência de Hidratação',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Sequência atual: ${_hydrationStreak.currentStreak} dias'),
            const SizedBox(height: 8),
            Text('🏆 Melhor sequência: ${_hydrationStreak.longestStreak} dias'),
            const SizedBox(height: 16),
            Text(
              _hydrationStreak.currentStreak == 0
                ? 'Atinja sua meta diária para começar uma nova sequência! 💪'
                : 'Continue bebendo água todos os dias para manter sua sequência! 🎀',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi! 💖'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _dailyGoal > 0 ? _currentGlasses / _dailyGoal : 0.0;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 30),
                
                // Progress Indicator
                AnimatedBuilder(
                  animation: _celebrationAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_celebrationAnimation.value * 0.1),
                      child: ProgressIndicatorWidget(
                        current: _currentGlasses,
                        goal: _dailyGoal,
                        progress: progress,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Water Counter
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: WaterCounterWidget(
                        currentGlasses: _currentGlasses,
                        onAddWater: _addWater,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                
                // Water Reminder Countdown
                const WaterReminderCountdown(),
                const SizedBox(height: 20),
                
                // Daily Stats Card
                _buildDailyStatsCard(),
                const SizedBox(height: 20),
                
                // Motivation Message
                _buildMotivationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final userName = _userProfile?.name ?? 'Usuário';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, $userName! 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Como está sua hidratação hoje?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        StreakTooltip(
          streak: _hydrationStreak,
          child: StreakWidget(
            streak: _hydrationStreak,
            onTap: _showStreakInfo,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyStatsCard() {
    final theme = Theme.of(context);
    final percentage = _dailyGoal > 0 
        ? ((_currentGlasses / _dailyGoal) * 100).round() 
        : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_drink,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progresso de Hoje',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_currentGlasses de $_dailyGoal copos ($percentage%)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    final theme = Theme.of(context);
    
    String motivationMessage;
    IconData motivationIcon;
    Color cardColor;
    
    final percentage = _dailyGoal > 0 
        ? (_currentGlasses / _dailyGoal) * 100 
        : 0.0;
    
    if (percentage >= 100) {
      motivationMessage = '🎉 Incrível! Você atingiu sua meta! A Kitty está orgulhosa! 💖';
      motivationIcon = Icons.celebration;
      cardColor = Colors.green[100]!;
    } else if (percentage >= 75) {
      motivationMessage = '🌟 Quase lá! Você está indo super bem! Continue assim! ✨';
      motivationIcon = Icons.star;
      cardColor = Colors.orange[100]!;
    } else if (percentage >= 50) {
      motivationMessage = '💪 Você está na metade do caminho! A  Kitty acredita em você! 🎀';
      motivationIcon = Icons.favorite;
      cardColor = Colors.blue[100]!;
    } else if (percentage >= 25) {
      motivationMessage = '🌸 Bom começo! Que tal mais um copinho d\'água? 💧';
      motivationIcon = Icons.local_drink;
      cardColor = theme.colorScheme.primaryContainer;
    } else {
      motivationMessage = '🌈 Vamos começar? A Hello Kitty está aqui para te lembrar! 💖';
      motivationIcon = Icons.emoji_emotions;
      cardColor = theme.colorScheme.primaryContainer;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            motivationIcon,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              motivationMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}