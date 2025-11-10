class WaterIntake {
  final String id;
  final DateTime date;
  final int glasses;
  final DateTime timestamp;

  WaterIntake({
    required this.id,
    required this.date,
    required this.glasses,
    required this.timestamp,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      glasses: json['glasses'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'glasses': glasses,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  WaterIntake copyWith({
    String? id,
    DateTime? date,
    int? glasses,
    DateTime? timestamp,
  }) {
    return WaterIntake(
      id: id ?? this.id,
      date: date ?? this.date,
      glasses: glasses ?? this.glasses,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'WaterIntake(id: $id, date: $date, glasses: $glasses, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WaterIntake && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DailyGoal {
  final int glasses;
  final DateTime lastUpdated;

  DailyGoal({
    required this.glasses,
    required this.lastUpdated,
  });

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      glasses: json['glasses'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'glasses': glasses,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  DailyGoal copyWith({
    int? glasses,
    DateTime? lastUpdated,
  }) {
    return DailyGoal(
      glasses: glasses ?? this.glasses,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class WeeklyStats {
  final String week;
  final int totalGlasses;
  final double averagePerDay;
  final int daysTracked;

  WeeklyStats({
    required this.week,
    required this.totalGlasses,
    required this.averagePerDay,
    required this.daysTracked,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      week: json['week'] as String,
      totalGlasses: json['totalGlasses'] as int,
      averagePerDay: json['averagePerDay'] as double,
      daysTracked: json['daysTracked'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'totalGlasses': totalGlasses,
      'averagePerDay': averagePerDay,
      'daysTracked': daysTracked,
    };
  }

  WeeklyStats copyWith({
    String? week,
    int? totalGlasses,
    double? averagePerDay,
    int? daysTracked,
  }) {
    return WeeklyStats(
      week: week ?? this.week,
      totalGlasses: totalGlasses ?? this.totalGlasses,
      averagePerDay: averagePerDay ?? this.averagePerDay,
      daysTracked: daysTracked ?? this.daysTracked,
    );
  }
}

class NotificationSettings {
  final bool enabled;
  final int frequency; // minutos entre lembretes
  final String startTime; // formato HH:mm
  final String endTime; // formato HH:mm
  final List<String> customMessages;

  NotificationSettings({
    required this.enabled,
    required this.frequency,
    required this.startTime,
    required this.endTime,
    required this.customMessages,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool,
      frequency: json['frequency'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      customMessages: List<String>.from(json['customMessages'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequency': frequency,
      'startTime': startTime,
      'endTime': endTime,
      'customMessages': customMessages,
    };
  }

  NotificationSettings copyWith({
    bool? enabled,
    int? frequency,
    String? startTime,
    String? endTime,
    List<String>? customMessages,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      customMessages: customMessages ?? this.customMessages,
    );
  }
}

class HydrationStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final List<String> completedDates; // ISO strings das datas que atingiu a meta

  HydrationStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.completedDates = const [],
  });

  factory HydrationStreak.fromJson(Map<String, dynamic> json) {
    return HydrationStreak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null 
        ? DateTime.parse(json['lastCompletedDate'] as String)
        : null,
      completedDates: List<String>.from(json['completedDates'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'completedDates': completedDates,
    };
  }

  HydrationStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    List<String>? completedDates,
  }) {
    return HydrationStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  /// Atualiza o streak quando uma meta é atingida
  HydrationStreak updateStreak(DateTime completedDate) {
    final dateString = _formatDateString(completedDate);
    
    // Se já completou hoje, não altera
    if (completedDates.contains(dateString)) {
      return this;
    }

    final newCompletedDates = [...completedDates, dateString];
    
    // Verifica se é consecutivo
    final yesterday = completedDate.subtract(const Duration(days: 1));
    final yesterdayString = _formatDateString(yesterday);
    
    int newCurrentStreak;
    if (completedDates.contains(yesterdayString) || currentStreak == 0) {
      newCurrentStreak = currentStreak + 1;
    } else {
      newCurrentStreak = 1; // Reinicia streak
    }
    
    final newLongestStreak = newCurrentStreak > longestStreak 
      ? newCurrentStreak 
      : longestStreak;
    
    return HydrationStreak(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastCompletedDate: completedDate,
      completedDates: newCompletedDates,
    );
  }

  /// Verifica e atualiza streak considerando dias perdidos
  HydrationStreak checkAndUpdateStreak(DateTime today) {
    if (lastCompletedDate == null) return this;
    
    final todayString = _formatDateString(today);
    final yesterdayString = _formatDateString(today.subtract(const Duration(days: 1)));
    
    // Se hoje já foi completado, não faz nada
    if (completedDates.contains(todayString)) {
      return this;
    }
    
    final daysSinceLastCompleted = today.difference(lastCompletedDate!).inDays;
    
    // Se passou mais de 1 dia sem completar, quebra o streak
    if (daysSinceLastCompleted > 1) {
      return copyWith(currentStreak: 0);
    }
    
    // Se é o dia seguinte e ontem não foi completado, quebra o streak
    if (daysSinceLastCompleted == 1 && !completedDates.contains(yesterdayString)) {
      return copyWith(currentStreak: 0);
    }
    
    return this;
  }

  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class UserProfile {
  final String name;
  final DailyGoal dailyGoal;
  final NotificationSettings notificationSettings;
  final DateTime createdAt;
  final HydrationStreak hydrationStreak;

  UserProfile({
    required this.name,
    required this.dailyGoal,
    required this.notificationSettings,
    required this.createdAt,
    HydrationStreak? hydrationStreak,
  }) : hydrationStreak = hydrationStreak ?? HydrationStreak();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      dailyGoal: DailyGoal.fromJson(json['dailyGoal'] as Map<String, dynamic>),
      notificationSettings: NotificationSettings.fromJson(
        json['notificationSettings'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      hydrationStreak: json['hydrationStreak'] != null 
        ? HydrationStreak.fromJson(json['hydrationStreak'] as Map<String, dynamic>)
        : HydrationStreak(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dailyGoal': dailyGoal.toJson(),
      'notificationSettings': notificationSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'hydrationStreak': hydrationStreak.toJson(),
    };
  }

  UserProfile copyWith({
    String? name,
    DailyGoal? dailyGoal,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    HydrationStreak? hydrationStreak,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      hydrationStreak: hydrationStreak ?? this.hydrationStreak,
    );
  }
}