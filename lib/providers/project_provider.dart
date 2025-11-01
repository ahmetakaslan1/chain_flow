import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/hive_service.dart';
import 'package:chain/services/notification_service.dart';
import 'package:hive/hive.dart';
import 'package:chain/models/day_status.dart';

class ProjectProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  late final NotificationService _notificationService;
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  ProjectProvider({NotificationService? notificationService}) {
    _notificationService = notificationService ?? NotificationService();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    _projects = _hiveService.getAllProjects();
    await _backfillMissedDays();
    notifyListeners();
    await checkChainAnalysis();
  }

  Future<void> _backfillMissedDays() async {
    final DateTime today = DateTime.now();
    for (final project in _projects) {
      if (project.startDate.isAfter(today)) continue;
      bool projectChanged = false;
      DateTime cursor = DateTime(project.startDate.year, project.startDate.month, project.startDate.day);
      final DateTime endDate = DateTime(today.year, today.month, today.day);

      while (!cursor.isAfter(endDate)) {
        final exists = project.dailyStatus.any((day) =>
            day.date.year == cursor.year && day.date.month == cursor.month && day.date.day == cursor.day);
        if (!exists) {
          project.dailyStatus.add(DayStatus(date: cursor, isCompleted: false));
          projectChanged = true;
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      if (projectChanged) {
        project.dailyStatus.sort((a, b) => a.date.compareTo(b.date));
        await _hiveService.updateProject(project);
      }
    }
  }

  Future<void> addProject(Project project) async {
    await _hiveService.addProject(project);
    await _loadProjects();
  }

  Future<void> updateProject(Project project) async {
    await _hiveService.updateProject(project);
    await _loadProjects();
  }

  Future<void> deleteProject(String projectId) async {
    await _hiveService.deleteProject(projectId);
    await _loadProjects();
  }

  Future<void> clearAllProjects() async {
    await _hiveService.clearAllProjects();
    await _loadProjects();
  }

  Future<void> checkChainAnalysis() async {
    final settingsBox = Hive.box('settings');
    final threshold = settingsBox.get('chainAnalysisThreshold', defaultValue: 3);
    final language = settingsBox.get('appLocale', defaultValue: 'tr') as String;
    final now = DateTime.now();

    for (var project in _projects) {
      if (project.isCompleted) continue;

      final int totalDays = now.difference(project.startDate).inDays;
      if (totalDays < 0) {
        continue;
      }
      int consecutiveMissedDays = 0;
      for (int i = 0; i <= totalDays; i++) {
        final date = DateTime(project.startDate.year, project.startDate.month, project.startDate.day)
            .add(Duration(days: i));
        final dayStatus = project.dailyStatus.firstWhere(
          (ds) => ds.date.year == date.year && ds.date.month == date.month && ds.date.day == date.day,
          orElse: () => DayStatus(date: date, isCompleted: false),
        );

        if (!dayStatus.isCompleted) {
          consecutiveMissedDays++;
        } else {
          consecutiveMissedDays = 0;
        }
      }

      if (consecutiveMissedDays >= threshold) {
        final title = language == 'en'
            ? 'Chain broken alert for ${project.name}!'
            : '${project.name} için zincir bozuldu!';
        final body = language == 'en'
            ? 'You have missed $consecutiveMissedDays consecutive days. Do you want to add a note?'
            : '$consecutiveMissedDays gündür ara verdin. Not eklemek ister misin?';
        await _notificationService.showNotification(
          project.id.hashCode,
          title,
          body,
          project.id,
        );
      }
    }
  }

  List<Project> getCompletedProjects() {
    return _projects.where((project) => project.isCompleted).toList();
  }

  List<Project> getActiveProjects() {
    return _projects.where((project) => !project.isCompleted).toList();
  }
}
