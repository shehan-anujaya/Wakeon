import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/models/driving_session.dart';

class SessionHistoryRepository {
  static const String _boxName = 'session_history';
  Box<DrivingSession>? _box;

  Future<Box<DrivingSession>> _getBox() async {
    _box ??= await Hive.openBox<DrivingSession>(_boxName);
    return _box!;
  }

  /// Save a completed driving session to history
  Future<void> saveSession(DrivingSession session) async {
    final box = await _getBox();
    await box.put(session.id, session);
  }

  /// Get all sessions from history
  Future<List<DrivingSession>> getAllSessions() async {
    final box = await _getBox();
    return box.values.toList();
  }

  /// Get sessions from the last N days
  Future<List<DrivingSession>> getRecentSessions({int days = 7}) async {
    final box = await _getBox();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return box.values
        .where((session) => session.startTime.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Get total driving duration across all sessions
  Duration getTotalDrivingTime(List<DrivingSession> sessions) {
    return sessions.fold(
      Duration.zero,
      (total, session) => total + session.duration,
    );
  }

  /// Get total alert count across all sessions
  int getTotalAlerts(List<DrivingSession> sessions) {
    return sessions.fold(
      0,
      (total, session) => total + session.drowsinessEventsCount,
    );
  }

  /// Calculate safety score based on alerts per hour of driving
  /// 100% = no alerts, decreases by 10% per alert per hour (capped at 0%)
  double calculateSafetyScore(List<DrivingSession> sessions) {
    if (sessions.isEmpty) return 100.0;
    
    final totalDuration = getTotalDrivingTime(sessions);
    if (totalDuration.inMinutes == 0) return 100.0;
    
    final totalAlerts = getTotalAlerts(sessions);
    final hoursOfDriving = totalDuration.inMinutes / 60.0;
    final alertsPerHour = totalAlerts / hoursOfDriving;
    
    // Each alert per hour reduces score by 15%, minimum 0%
    final score = 100.0 - (alertsPerHour * 15.0);
    return score.clamp(0.0, 100.0);
  }

  /// Get driving hours grouped by day for the last 7 days
  Map<int, double> getWeeklyDrivingHours(List<DrivingSession> sessions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Initialize map with 0 hours for each day (0 = Monday, 6 = Sunday)
    final Map<int, double> dailyHours = {
      0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0,
    };
    
    for (final session in sessions) {
      final sessionDate = session.startTime;
      // Only include sessions from this week
      if (sessionDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        final dayIndex = sessionDate.weekday - 1; // 0 = Monday
        if (dayIndex >= 0 && dayIndex <= 6) {
          final hours = session.duration.inMinutes / 60.0;
          dailyHours[dayIndex] = (dailyHours[dayIndex] ?? 0) + hours;
        }
      }
    }
    
    return dailyHours;
  }

  /// Get alerts grouped by day for the last 7 days
  Map<int, int> getWeeklyAlerts(List<DrivingSession> sessions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Initialize map with 0 alerts for each day
    final Map<int, int> dailyAlerts = {
      0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
    };
    
    for (final session in sessions) {
      final sessionDate = session.startTime;
      if (sessionDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        final dayIndex = sessionDate.weekday - 1;
        if (dayIndex >= 0 && dayIndex <= 6) {
          dailyAlerts[dayIndex] = (dailyAlerts[dayIndex] ?? 0) + session.drowsinessEventsCount;
        }
      }
    }
    
    return dailyAlerts;
  }

  /// Delete a session from history
  Future<void> deleteSession(String sessionId) async {
    final box = await _getBox();
    await box.delete(sessionId);
  }

  /// Clear all session history
  Future<void> clearHistory() async {
    final box = await _getBox();
    await box.clear();
  }
}
