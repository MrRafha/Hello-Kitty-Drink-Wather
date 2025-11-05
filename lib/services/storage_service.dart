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
    );
  }
}