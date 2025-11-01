
import 'package:hive/hive.dart';
import 'day_status.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime startDate;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  late List<DayStatus> dailyStatus;

  @HiveField(5)
  late List<String> notes;

  Project({
    required this.id,
    required this.name,
    required this.startDate,
    this.isCompleted = false,
    List<DayStatus>? dailyStatus,
    List<String>? notes,
  })  : dailyStatus = dailyStatus ?? [],
        notes = notes ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'isCompleted': isCompleted,
        'dailyStatus': dailyStatus.map((ds) => ds.toJson()).toList(),
        'notes': notes,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        isCompleted: json['isCompleted'] as bool,
        dailyStatus: (json['dailyStatus'] as List<dynamic>)
            .map((e) => DayStatus.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: (json['notes'] as List<dynamic>).map((e) => e as String).toList(),
      );
}
