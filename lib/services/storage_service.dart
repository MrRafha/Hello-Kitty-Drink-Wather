import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_models.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  static const String _waterIntakeKey = 'water_intake';
  static const String _userProfileKey = 'user_profile';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Water Intake Methods
  Future<void> saveWaterIntake(List<WaterIntake> intake) async {
    final jsonList = intake.map((item) => item.toJson()).toList();
    await _prefs.setString(_waterIntakeKey, jsonEncode(jsonList));
  }

  Future<List<WaterIntake>> getWaterIntake() async {
    final jsonString = _prefs.getString(_waterIntakeKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => WaterIntake.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar dados de água: $e');
      return [];
    }
  }

  Future<List<WaterIntake>> addWaterGlass({int glasses = 1}) async {
    final existingIntake = await getWaterIntake();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Procurar registro de hoje
    final todayIntakeIndex = existingIntake.indexWhere(
      (intake) => isSameDay(intake.date, todayDate),
    );

    if (todayIntakeIndex >= 0) {
      // Atualizar registro existente
      final updatedIntake = existingIntake[todayIntakeIndex].copyWith(
        glasses: existingIntake[todayIntakeIndex].glasses + glasses,
        timestamp: DateTime.now(),
      );
      existingIntake[todayIntakeIndex] = updatedIntake;
    } else {
      // Criar novo registro
      final newIntake = WaterIntake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: todayDate,
        glasses: glasses,
        timestamp: DateTime.now(),
      );
      existingIntake.add(newIntake);
    }

    await saveWaterIntake(existingIntake);
    return existingIntake;
  }

  Future<int> getTodayIntake() async {
    final intake = await getWaterIntake();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final todayIntake = intake.firstWhere(
      (item) => isSameDay(item.date, todayDate),
      orElse: () => WaterIntake(
        id: '',
        date: todayDate,
        glasses: 0,
        timestamp: DateTime.now(),
      ),
    );

    return todayIntake.glasses;
  }

  // User Profile Methods
  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    final jsonString = _prefs.getString(_userProfileKey);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (e) {
      print('Erro ao carregar perfil do usuário: $e');
      return null;
    }
  }

  // Weekly Stats Methods
  Future<List<WeeklyStats>> calculateWeeklyStats() async {
    final intake = await getWaterIntake();
    final Map<String, WeeklyStats> statsMap = {};

    for (final item in intake) {
      final weekKey = getWeekKey(item.date);

      if (statsMap.containsKey(weekKey)) {
        final current = statsMap[weekKey]!;
        statsMap[weekKey] = current.copyWith(
          totalGlasses: current.totalGlasses + item.glasses,
          daysTracked: current.daysTracked + 1,
        );
      } else {
        statsMap[weekKey] = WeeklyStats(
          week: weekKey,
          totalGlasses: item.glasses,
          averagePerDay: 0, // Será calculado depois
          daysTracked: 1,
        );
      }
    }

    // Calcular médias
    final stats = statsMap.values.map((stat) {
      return stat.copyWith(
        averagePerDay: stat.daysTracked > 0 ? stat.totalGlasses / stat.daysTracked : 0,
      );
    }).toList();

    // Ordenar por semana (mais recente primeiro)
    stats.sort((a, b) => b.week.compareTo(a.week));
    return stats;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.remove(_waterIntakeKey);
    await _prefs.remove(_userProfileKey);
  }

  // Utility Methods
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String getWeekKey(DateTime date) {
    final year = date.year;
    final weekNumber = getWeekNumber(date);
    return '$year-W${weekNumber.toString().padLeft(2, '0')}';
  }

  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  // Hydration Streak Methods
  Future<HydrationStreak> getHydrationStreak() async {
    final profile = await getUserProfile();
    return profile?.hydrationStreak ?? HydrationStreak();
  }

  Future<void> updateStreakForGoalAchieved(int currentGlasses, int dailyGoal) async {
    print('DEBUG STORAGE: updateStreakForGoalAchieved chamado - Copos: $currentGlasses, Meta: $dailyGoal');
    
    if (currentGlasses < dailyGoal) {
      print('DEBUG STORAGE: Meta não atingida, não atualizando streak');
      return;
    }

    final profile = await getUserProfile();
    if (profile == null) {
      print('DEBUG STORAGE: Perfil não encontrado');
      return;
    }

    print('DEBUG STORAGE: Perfil encontrado, streak atual: ${profile.hydrationStreak.currentStreak}');
    
    final today = DateTime.now();
    final updatedStreak = profile.hydrationStreak.updateStreak(today);
    
    final updatedProfile = profile.copyWith(hydrationStreak: updatedStreak);
    await saveUserProfile(updatedProfile);
    
    print('DEBUG STORAGE: Streak atualizado e salvo - Atual: ${updatedStreak.currentStreak}, Máximo: ${updatedStreak.longestStreak}');
  }

  Future<void> checkAndUpdateStreakDaily() async {
    final profile = await getUserProfile();
    if (profile == null) return;

    final today = DateTime.now();
    final updatedStreak = profile.hydrationStreak.checkAndUpdateStreak(today);
    
    // Se o streak mudou (foi quebrado), salva
    if (updatedStreak.currentStreak != profile.hydrationStreak.currentStreak) {
      final updatedProfile = profile.copyWith(hydrationStreak: updatedStreak);
      await saveUserProfile(updatedProfile);
      print('DEBUG: Streak verificado e atualizado para: ${updatedStreak.currentStreak}');
    }
  }

  Future<void> checkStreakAtEndOfDay(int currentGlasses, int dailyGoal, [DateTime? checkDate]) async {
    final profile = await getUserProfile();
    if (profile == null) return;

    final dateToCheck = checkDate ?? DateTime.now().subtract(const Duration(days: 1));
    final dateString = '${dateToCheck.year}-${dateToCheck.month.toString().padLeft(2, '0')}-${dateToCheck.day.toString().padLeft(2, '0')}';
    
    // Verificar se o usuário atingiu a meta na data especificada
    final dateIntake = await _getIntakeForDate(dateToCheck);
    
    // Se não atingiu a meta na data e ainda não está marcado como completado
    if (dateIntake < dailyGoal && !profile.hydrationStreak.completedDates.contains(dateString)) {
      // Quebrar o streak se havia um ativo
      if (profile.hydrationStreak.currentStreak > 0) {
        final brokenStreak = profile.hydrationStreak.copyWith(currentStreak: 0);
        final updatedProfile = profile.copyWith(hydrationStreak: brokenStreak);
        await saveUserProfile(updatedProfile);
        print('DEBUG: Streak quebrado por não atingir meta em $dateString: ${profile.hydrationStreak.currentStreak} -> 0');
      }
    }
  }

  Future<int> _getIntakeForDate(DateTime date) async {
    final allIntake = await getWaterIntake();
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    int totalGlasses = 0;
    for (final intake in allIntake) {
      if (isSameDay(intake.date, dateOnly)) {
        totalGlasses += intake.glasses;
      }
    }
    
    return totalGlasses;
  }

  // Get default user profile
  UserProfile getDefaultProfile() {
    return UserProfile(
      name: 'Usuário',
      dailyGoal: DailyGoal(
        glasses: 8,
        lastUpdated: DateTime.now(),
      ),
      notificationSettings: NotificationSettings(
        enabled: true,
        frequency: 60, // 1 hora
        startTime: '08:00',
        endTime: '20:00',
        customMessages: [],
      ),
      createdAt: DateTime.now(),
      hydrationStreak: HydrationStreak(),
    );
  }
}