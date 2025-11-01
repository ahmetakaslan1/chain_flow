
import 'package:hive/hive.dart';

part 'day_status.g.dart';

@HiveType(typeId: 1)
class DayStatus extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late bool isCompleted;

  DayStatus({required this.date, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory DayStatus.fromJson(Map<String, dynamic> json) => DayStatus(
        date: DateTime.parse(json['date'] as String),
        isCompleted: json['isCompleted'] as bool,
      );
}
