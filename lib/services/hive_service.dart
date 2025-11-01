import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';
import '../models/day_status.dart';

class HiveService {
  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(DayStatusAdapter());
    await Hive.openBox<Project>('projects');
  }

  Box<Project> get projectBox => Hive.box<Project>('projects');

  Future<void> addProject(Project project) async {
    await projectBox.put(project.id, project);
  }

  Future<void> updateProject(Project project) async {
    await project.save();
  }

  Future<void> deleteProject(String projectId) async {
    await projectBox.delete(projectId);
  }

  Future<void> clearAllProjects() async {
    await projectBox.clear();
  }

  List<Project> getAllProjects() {
    return projectBox.values.toList();
  }

  List<Project> getProjects({bool completed = false}) {
    return projectBox.values.where((project) => project.isCompleted == completed).toList();
  }
}
