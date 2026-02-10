import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/driving_session.dart';
import '../data/session_history_repository.dart';

/// Provider for the session history repository
final sessionHistoryRepositoryProvider = Provider<SessionHistoryRepository>((ref) {
  return SessionHistoryRepository();
});

/// Analytics data model
class AnalyticsData {
  final List<DrivingSession> allSessions;
  final List<DrivingSession> recentSessions;
  final Duration totalDrivingTime;
  final int totalAlerts;
  final int totalSessions;
  final double safetyScore;
  final Map<int, double> weeklyDrivingHours;
  final Map<int, int> weeklyAlerts;
  final bool isLoading;

  const AnalyticsData({
    this.allSessions = const [],
    this.recentSessions = const [],
    this.totalDrivingTime = Duration.zero,
    this.totalAlerts = 0,
    this.totalSessions = 0,
    this.safetyScore = 100.0,
    this.weeklyDrivingHours = const {},
    this.weeklyAlerts = const {},
    this.isLoading = true,
  });

  /// Get formatted total driving time (e.g., "24h", "2h 30m")
  String get formattedTotalTime {
    final hours = totalDrivingTime.inHours;
    final minutes = totalDrivingTime.inMinutes.remainder(60);
    
    if (hours == 0 && minutes == 0) return '0m';
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  /// Get formatted safety score (e.g., "92%")
  String get formattedSafetyScore => '${safetyScore.round()}%';

  AnalyticsData copyWith({
    List<DrivingSession>? allSessions,
    List<DrivingSession>? recentSessions,
    Duration? totalDrivingTime,
    int? totalAlerts,
    int? totalSessions,
    double? safetyScore,
    Map<int, double>? weeklyDrivingHours,
    Map<int, int>? weeklyAlerts,
    bool? isLoading,
  }) {
    return AnalyticsData(
      allSessions: allSessions ?? this.allSessions,
      recentSessions: recentSessions ?? this.recentSessions,
      totalDrivingTime: totalDrivingTime ?? this.totalDrivingTime,
      totalAlerts: totalAlerts ?? this.totalAlerts,
      totalSessions: totalSessions ?? this.totalSessions,
      safetyScore: safetyScore ?? this.safetyScore,
      weeklyDrivingHours: weeklyDrivingHours ?? this.weeklyDrivingHours,
      weeklyAlerts: weeklyAlerts ?? this.weeklyAlerts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Analytics provider state notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsData> {
  final SessionHistoryRepository _repository;

  AnalyticsNotifier(this._repository) : super(const AnalyticsData());

  /// Load all analytics data from the repository
  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true);

    try {
      final allSessions = await _repository.getAllSessions();
      final recentSessions = await _repository.getRecentSessions(days: 30);
      
      final totalDrivingTime = _repository.getTotalDrivingTime(allSessions);
      final totalAlerts = _repository.getTotalAlerts(allSessions);
      final safetyScore = _repository.calculateSafetyScore(allSessions);
      final weeklyDrivingHours = _repository.getWeeklyDrivingHours(allSessions);
      final weeklyAlerts = _repository.getWeeklyAlerts(allSessions);

      state = AnalyticsData(
        allSessions: allSessions,
        recentSessions: recentSessions.take(5).toList(),
        totalDrivingTime: totalDrivingTime,
        totalAlerts: totalAlerts,
        totalSessions: allSessions.length,
        safetyScore: safetyScore,
        weeklyDrivingHours: weeklyDrivingHours,
        weeklyAlerts: weeklyAlerts,
        isLoading: false,
      );
    } catch (e) {
      // On error, set to empty data with loading false
      state = const AnalyticsData(isLoading: false);
    }
  }

  /// Add a completed session to history and refresh analytics
  Future<void> addSession(DrivingSession session) async {
    await _repository.saveSession(session);
    await loadAnalytics();
  }

  /// Clear all session history
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    await loadAnalytics();
  }
}

/// Main analytics provider
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsData>((ref) {
  final repository = ref.watch(sessionHistoryRepositoryProvider);
  return AnalyticsNotifier(repository);
});
